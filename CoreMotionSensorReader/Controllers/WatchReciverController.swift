//
//  WatchReciverViewModel.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 23.03.25.
//

import Foundation
import WatchConnectivity

@Observable
class WatchReciverController: NSObject, WCSessionDelegate {
    
    // MARK: - Class loading
    let csvWriter = WatchCsvWriter()
    let soundservice = SoundService()
    let extract = FeatureExtractor()
    let userMovementDetection = UserMovementDetection()
    let watchThresholdservice = WatchThreshold()
    
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
    
    
    
    var reducedFeatureLabelAll: String = "-"
    
    var fullFeatureLabelAll: String = "-"
    
    let modelService = ModelService()
    
    
    var receivedCount: Int = 0
    
    var frequencyHistory: [Int] = []
    let historySize = 5
    
    
    let windowSize: TimeInterval = 1.54
    
    var sensorBuffer: [SensorData] = []
    
    //MARK: - SlidingWindow var
    var slidingWindow: [SensorData] = []
    let slidingWindowSize = 65
    
    
    var isUserMoving: Bool = false
    var isUserMovingInformation: String = "-"
    
    //MARK: - Threshhold vars:
    var armPositionThreshholdLabel: String = "-"
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    
    //MARK: - Watch Connectivity
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
                    
                    let filter = SensorDataProcessor(alpha: 0.2)
                    let filteredSensorArray = sensorArray.map { filter.processData($0) }
                    
                    
                    if self.isCollectingTrainData {
                        self.tempData.append(contentsOf: sensorArray)
                    }
                    
                    if filteredSensorArray.last != nil {
                        self.armPositionThreshholdLabel = self.watchThresholdservice.getThresholdLabel(data: sensorArray.last!)
                    }
                    
                    
                    /*
                     if sensorArray.last != nil {
                         self.armPositionThreshholdLabel = self.watchThresholdservice.getThresholdLabel(data: sensorArray.last!)
                         
                     }
                     */
                
                    sensorArray.forEach {
                        self.processData(data: $0)
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Timer and Exports
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
    
    
    // MARK: - CSV Export
    func exportToCsv(data: [SensorData], to fileName: String) {
        csvWriter.exportCSV(from: data, to: fileName)
    }
    
    func exportToCsv(to fileName: String) {
        csvWriter.exportCSV(from: self.sensorData, to: fileName)
    }
    
    
    // MARK: - Array Size and Time
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
    
    
    // MARK: - Haptic Feedback
    func sendHapticFeedback() {
        let dict = ["haptic": "true"]
        
        if session.activationState == .activated && session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        } else {
            print("Session nicht erreichbar")
        }
    }
    
    
    // MARK: Sliding Window, Feature extractor
    func processData(data: SensorData) {
        
        slidingWindow.append(data)
        sensorBuffer.append(data)
        
        if slidingWindow.count > slidingWindowSize {
            
            slidingWindow.removeFirst()
            
            let features = extract.computeFeatures(from: slidingWindow)
            let featuresAll = extract.computeFeaturesAllLabel(from: slidingWindow)
            
            if let prediction = modelService?.classifyReducedFeatures(features: features) {
                self.reducedFeatureLabelAll = prediction
            }
            
            if let predictionAllLabel = modelService?.classifyFullFeatures(features: featuresAll) {
                self.fullFeatureLabelAll = predictionAllLabel
            }
            
            updateUserMovingInfo(motionData: slidingWindow)
            updateSamplingFrequency()
        }
    }
    
    
    
    // MARK: - Abtastrate Berechnen
    private func updateSamplingFrequency() {
        guard sensorBuffer.count >= 2 else { return }
        
        let firstTime = sensorBuffer.first!.timestamp
        let lastTime = sensorBuffer.last!.timestamp
        let timeSpan = lastTime.timeIntervalSince(firstTime)
        
        if timeSpan > 0 {
            let samplesCount = sensorBuffer.count - 1
            let frequency = Int(round(Double(samplesCount) / timeSpan))
            
            frequencyHistory.append(frequency)
            if frequencyHistory.count > historySize {
                frequencyHistory.removeFirst()
            }
            
            //let avgFrequency = frequencyHistory.reduce(0, +) / frequencyHistory.count
            
            
        }
    }
    
    
    //MARK: - Update information if user is moving
    private func updateUserMovingInfo(motionData: [SensorData]) {
        
        if (userMovementDetection.isActiveMovement(from: motionData)) {
            isUserMoving = true
            isUserMovingInformation = "Aktiv"
        } else {
            isUserMoving = false
            isUserMovingInformation = "Inaktiv"
        }
        
    }
}
