//
//  TherapySessionDelegate.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 19.06.24.
//

import Foundation
import WatchKit

class TherapySessionDelegate: NSObject, WKExtensionDelegate, WKExtendedRuntimeSessionDelegate {
    
    static var shared: TherapySessionDelegate!
    
    var extendedRuntimeSession: WKExtendedRuntimeSession?
    
    
    override init() {
        super.init()
        TherapySessionDelegate.shared = self
    }
    
    func startExtendedRuntimeSession() {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        extendedRuntimeSession?.start()
    }
    
    func stopExtendedRuntimeSession() {
        if extendedRuntimeSession?.state == .running {
            extendedRuntimeSession?.invalidate()
        }
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Extended runtime session invalidated with reason: \(reason)")
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session started")
        extendedRuntimeSession.start()
        
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session will expire soon")
    }
}
