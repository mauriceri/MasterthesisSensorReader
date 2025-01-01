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
    var timerSeconds: Int = 30
    
    var prediction: String = "-"
    var modelPrediction: String = "-"
    
    var elapsedTime: TimeInterval = 0.0
    
    
    var isCollectingTrainData: Bool = false
    var isCountTimerRunning: Bool = false
    
    let watchPrediction = WatchPredicterService()
    let csvWriter = WatchCsvWriter()
    
    
    let soundservice = SoundService()
    
    
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
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data: Data = message["data"] as? Data else { return }
        
        var messageData = SensorData.decodeIt(data)
        messageData.elapsedTime = getElapsedTime()
        
        DispatchQueue.main.async {
            self.sensorData.append(messageData)
            self.lastSensorData = messageData
            
            if(self.isCollectingTrainData) {
                self.tempData.append(messageData)
            }
            
            self.prediction = self.watchPrediction.predictMovement(motionData: messageData)
            self.modelPrediction = self.watchPrediction.testPred(motionData: messageData)
        }
    }
    
    func startTimerAndExport(to fileName: String) {
        self.tempData.removeAll()
        self.isCollectingTrainData = true
        self.isCountTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
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
                self.timerSeconds = 30
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
        self.timerSeconds = 30
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
        var dict = ["haptic": "true"]
        
        if session.activationState == .activated && session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        } else {
            print("Session nicht erreichbar")
        }
    }
    
}
