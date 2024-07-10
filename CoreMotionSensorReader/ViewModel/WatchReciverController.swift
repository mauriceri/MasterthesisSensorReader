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
    
    
    let watchPrediction = WatchPredicterService()
    let csvWriter = CsvWriter(fileName: "watchtest.csv")

    
    
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
        
        let messageData = SensorData.decodeIt(data)
        
        DispatchQueue.main.async {
            self.lastSensorData = messageData
            self.sensorData.append(messageData)
            
            self.prediction = self.watchPrediction.predictMovement(motionData: messageData)
        }
    }
    
    func exportToCsv() {
        //csvWriter.writeCsv(data: nil)
    }
      
}
