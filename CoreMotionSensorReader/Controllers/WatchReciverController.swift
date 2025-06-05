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
    
    var filterSensorData = [SensorData]()
    
    var featureData = [SensorFeaturesAllLabel]()
    var scaledFeatureData = [ScaledFeature]()
    
    var tempData = [SensorData]()
    var filterdTempData = [SensorData]()
    
    private var timer: Timer?
    private var countTimer: Timer? = nil
    var timerSeconds: Int = 60
    
    var predictionRf: String = "-"
    var modelPrediction: String = "-"
    
    var elapsedTime: TimeInterval = 0.0
    
    
    var isCollectingTrainData: Bool = false
    var isCountTimerRunning: Bool = false
    

    let modelService = ModelService()
    
    
    var receivedCount: Int = 0
    
    var frequencyHistory: [Int] = []
    let historySize = 5
    
    
    let windowSize: TimeInterval = 1.54
    var sensorBuffer: [SensorData] = []
    

    //MARK: - Audiofeedback
    var mismatchTimer: Timer?
    var currentAcitivity = "Arm nach vorne"
    let soundService = SoundService()
    
    var isTherapyViewActive: Bool = false
    var isAudioFeedbackActive: Bool = false
    
    
    //MARK: - SlidingWindow var
    var slidingWindow: [SensorData] = []
    let slidingWindowSize = 65
    
    
    var isUserMoving: Bool = false
    var isUserMovingInformation: String = "-"
    
    //MARK: - Threshhold vars:
    var armPositionThreshholdLabel: String = "-"
    var activeMovingThreshhold: Double = 0.1
    
    
    
    //MARK: - Features vars
    var reducedLabelFeatures: SensorFeatures?
    var allLabelFeatures: SensorFeaturesAllLabel?
    
    
    //MARK: - Predictions
    var reducedRfFeatureLabelAll: String = "-"
    var fullRfFeatureLabelAll: String = "-"
    
    var decisionTreeLabelAll: String = "-"
    var knnLabelAll: String = "-"
    var svmLabelAll: String = "-"
    var svmResultString: String = "-"
    
    //MARK: - Modelflags
    var isReducedRandomForestActive: Bool = false
    
    var isFullRandomForestActive: Bool = false
    var isSVMActive: Bool = false
    var isMutliLayerPerceptronActive: Bool = false
    var isKNNActive: Bool = false
    var isDecisionTreeActive: Bool = false
    var isXGboostActive: Bool = false
    var isMlpActive: Bool = false
    
    //MARK: - Watch Connectivity
    
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
                    
                    let filter = SensorDataProcessor(alpha: 0.2)
                    let filteredSensorArray = sensorArray.map { filter.processData($0) }
                    
                    self.filterSensorData.append(contentsOf: filteredSensorArray)
                    
                    
                    if self.isCollectingTrainData {
                        self.tempData.append(contentsOf: sensorArray)
                        self.filterdTempData.append(contentsOf: filteredSensorArray)
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
    func startTimerAndExport(to fileName: String, to fileNameFeature: String) {
        self.tempData.removeAll()
        self.filterdTempData.removeAll()
        self.isCollectingTrainData = true
        self.isCountTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isCollectingTrainData = false
            self.exportToCsv(data: self.tempData, to: fileName)
            self.exportToFeatureCSV(to: fileNameFeature)
            self.tempData.removeAll()
            self.filterdTempData.removeAll()
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
    
    func exportToFeatureCSV(to fileName: String) {
        csvWriter.exportFeaturesCSV(from: self.featureData, to: fileName)
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
        self.featureData.removeAll()
        self.scaledFeatureData.removeAll()
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
            let scaledFeaturesAll = extract.scaleFeatures(features: featuresAll)
            
            
            
            self.featureData.append(featuresAll)
            self.scaledFeatureData.append(scaledFeaturesAll)
            
            self.reducedLabelFeatures = features
            self.allLabelFeatures = featuresAll
            
            if isReducedRandomForestActive, let prediction = modelService?.classifyRfReducedFeatures(features: features) {
                self.reducedRfFeatureLabelAll = prediction
            }
            
            if isFullRandomForestActive, let predictionAllLabel = modelService?.classifyRfFullFeatures(features: featuresAll) {
                self.fullRfFeatureLabelAll = predictionAllLabel
            }
            
            if isDecisionTreeActive, let decisionTreePrediction = modelService?.classifyDecisionTree(features: featuresAll) {
                self.decisionTreeLabelAll = decisionTreePrediction
            }
            
            if isKNNActive, let knnPrediction = modelService?.classifyKnn(features: scaledFeaturesAll) {
                self.knnLabelAll = knnPrediction
            }
            
            if isSVMActive, let (predictedLabel, resultString) = modelService?.classifySvm(features: scaledFeaturesAll) {
                self.svmLabelAll = predictedLabel ?? "-"
                self.svmResultString = resultString ?? "-"
                
                if self.svmLabelAll != self.currentAcitivity {
                    if mismatchTimer == nil {
                        startMismatchTimer()
                    }
                } else {
                    mismatchTimer?.invalidate()
                    mismatchTimer = nil
                }
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
        
        if (userMovementDetection.isActiveMovement(from: motionData, threshhold: self.activeMovingThreshhold)) {
            isUserMoving = true
            isUserMovingInformation = "Aktiv"
        } else {
            isUserMoving = false
            isUserMovingInformation = "Inaktiv"
        }
        
    }
    
    //MARK: - Audio Feedback
    func startMismatchTimer() {
        
        if self.isTherapyViewActive && self.isAudioFeedbackActive {
            mismatchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                self?.handleMismatchLongEnough()
                self?.sendHapticFeedback()
                self?.mismatchTimer = nil
            }
        }
       
    }

    func handleMismatchLongEnough() {
        soundservice.playBodyPosSound()
    }
}
