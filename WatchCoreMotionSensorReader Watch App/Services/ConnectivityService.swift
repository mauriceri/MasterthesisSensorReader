//
//  ConnectivityService.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import Foundation
import WatchConnectivity

class ConnectivityService: NSObject, WCSessionDelegate {
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print(activationState)
    }
    
    func sendSensorData(data: SensorData) {
        let dict: [String : Any] = ["data": data.encodeIt()]
        
        if session.activationState == .activated && session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        } else {
            print("Session nicht erreichbar")
        }
    }
    
}
