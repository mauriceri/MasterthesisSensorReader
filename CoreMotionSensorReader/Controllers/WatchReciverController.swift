//
//  WatchReciverViewModel.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 16.06.24.
//

import Foundation
import WatchConnectivity

@Observable
class WatchReciverController: NSObject, WCSessionDelegate {
    
    
    
    var lastSensorData: SensorData?
    var sensorData = [SensorData]()
    
    var tempData = [SensorData]()
    private var timer: Timer?
    private var countTimer: Timer? = nil
    var timerSeconds: Int = 60
    
    var prediction: String = "-"
    var modelPrediction: String = "-"
    
    var elapsedTime: TimeInterval = 0.0
    
    
    var isCollectingTrainData: Bool = false
    var isCountTimerRunning: Bool = false
    
    let watchPrediction = WatchPredicterService()
    let csvWriter = WatchCsvWriter()
    
    
    let soundservice = SoundService()
    
    
    let featureExtractor = FeatureProcessing()
    let modelService = ModelService()
    
    
    
    
    var currentFeatureStruct: SensorFeatures?
    
    var receivedCount: Int = 0
    var frequencyHistory: [Int] = []
    let historySize = 5
    
    
    //Daten aus Fenster
    var sensorBuffer: [SensorData] = []
    
    // Fixed sample count for 65Hz buffer (approximately 1 second of data)
    let fixedSampleCount = 65
    
    // Keep windowSize as a fallback mechanism
    let windowSize: TimeInterval = 1.54
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        session.activate()    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let sensorArray = try? JSONDecoder().decode([SensorData].self, from: messageData) {
                DispatchQueue.main.async {
                    self.sensorData.append(contentsOf: sensorArray)
                    self.lastSensorData = sensorArray.last
                    
                    if self.isCollectingTrainData {
                        self.tempData.append(contentsOf: sensorArray)
                    }

                    sensorArray.forEach { self.updateSensorBuffer(with: $0) }
                    
                }
            }
        }
    }
    
    func startTimerAndExport(to fileName: String) {
        self.tempData.removeAll()
        self.isCollectingTrainData = true
        self.isCountTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isCollectingTrainData = false
            self.exportToCsv(data: self.tempData, to: fileName)
            self.tempData.removeAll()
            self.soundservice.playSound()
            self.sendHapticFeedback()
        }
        
        countTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timerSeconds > 0 {
                self.timerSeconds -= 1
            } else {
                self.countTimer?.invalidate()
                self.countTimer = nil
                self.timerSeconds = 60
                self.isCountTimerRunning = false
            }
        }
    }
    
    func stopAllTimers() {
        self.isCollectingTrainData = false
        self.isCountTimerRunning = false
        self.timer?.invalidate()
        self.countTimer?.invalidate()
        self.timer = nil
        self.countTimer = nil
        self.timerSeconds = 60
    }
    
    
    func exportToCsv(data: [SensorData], to fileName: String) {
        csvWriter.exportCSV(from: data, to: fileName)
    }
    
    func exportToCsv(to fileName: String) {
        csvWriter.exportCSV(from: self.sensorData, to: fileName)
    }
    
    func getArraySize() -> Int {
        return self.sensorData.count
    }
    
    func getTempArraySitze () -> Int {
        return self.tempData.count
    }
    
    func clearData() -> Void {
        self.sensorData.removeAll()
        self.elapsedTime = 0.0
    }
    
    func getElapsedTime() -> TimeInterval {
        guard let first = sensorData.first, let last = sensorData.last else {
            return 0
        }
        return last.timestamp.timeIntervalSince(first.timestamp)
    }
    
    func sendHapticFeedback() {
        let dict = ["haptic": "true"]
        
        if session.activationState == .activated && session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        } else {
            print("Session nicht erreichbar")
        }
    }
    
  
 // MARK: Sliding Window, Feature extractor
    func updateSensorBuffer(with newData: SensorData) {
        // Add new data to buffer
        sensorBuffer.append(newData)
        
        // Use sample count as primary mechanism to maintain window size
        if sensorBuffer.count > fixedSampleCount {
            // Remove oldest samples to maintain fixed window size
            sensorBuffer = Array(sensorBuffer.suffix(fixedSampleCount))
        }
        
        // Time-based fallback to ensure data isn't too old (in case of sampling rate changes)
        if let oldestTimestamp = sensorBuffer.first?.timestamp {
            let currentTime = newData.timestamp
            let timeDifference = currentTime.timeIntervalSince(oldestTimestamp)
            
            // If time window is much larger than expected, trim it
            if timeDifference > windowSize * 1.5 {
                sensorBuffer = sensorBuffer.filter {
                    currentTime.timeIntervalSince($0.timestamp) <= windowSize
                }
            }
        }
        
        // Process window if we have enough data
        if sensorBuffer.count >= fixedSampleCount/2 {
            // Compute features from the sensor buffer
            let features = featureExtractor.computeFeatures(from: sensorBuffer)
            
            // Standardize features for the model
           let scaledFeatures = featureExtractor.standardizeFeatures(features)
            
            // Get prediction from model
            if let prediction = modelService?.classify(features: scaledFeatures) {
                self.modelPrediction = prediction
            }
            
            // Store current features
            self.currentFeatureStruct = features
            
            // Update sampling frequency
            updateSamplingFrequency()
        }
    }
    
    // Calculate and update the current sampling frequency
    private func updateSamplingFrequency() {
        guard sensorBuffer.count >= 2 else { return }
        
        // Calculate time span
        let firstTime = sensorBuffer.first!.timestamp
        let lastTime = sensorBuffer.last!.timestamp
        let timeSpan = lastTime.timeIntervalSince(firstTime)
        
        if timeSpan > 0 {
            // Calculate frequency (samples per second)
            let samplesCount = sensorBuffer.count - 1 // Count transitions, not samples
            let frequency = Int(round(Double(samplesCount) / timeSpan))
            
            // Update history
            frequencyHistory.append(frequency)
            if frequencyHistory.count > historySize {
                frequencyHistory.removeFirst()
            }
            
            // Calculate average frequency
            let avgFrequency = frequencyHistory.reduce(0, +) / frequencyHistory.count
            
            // Could use this to adjust buffer size if needed
            print("Current sampling frequency: \(avgFrequency) Hz")
        }
    }
}
