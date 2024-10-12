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
    
    var prediction: String = "-"
    var modelPrediction: String = "-"
    
    var elapsedTime: TimeInterval = 0.0
    
    
    let watchPrediction = WatchPredicterService()
    let csvWriter = WatchCsvWriter()
    
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
            self.prediction = self.watchPrediction.predictMovement(motionData: messageData)
            self.modelPrediction = self.watchPrediction.testPred(motionData: messageData)
        }
    }
    
    func exportToCsv() {
        csvWriter.exportCSV(from: self.sensorData, to: "watchdata.csv")
    }
    
    func getArraySize() -> Int {
        return self.sensorData.count
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
    
}
