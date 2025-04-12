//
//  WatchThreshhold.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 24.03.25.
//

import Foundation

class WatchThreshold {
    
    var armfrontraisYaw = 1.21
    var armfrontraisPitch = 0.04
    var armfrontraisRoll = 0.08
    
    var armtopraiseYaw = 1.4
    var armtopraisePitch = 0.2
    var armtopraiseRoll = -1.3
    
    let tolerance: Double = 0.5
    
    func getThresholdLabel(data: SensorData) -> String {
        let yaw = data.deviceMotionData?.yaw ?? 0.0
        let pitch = data.deviceMotionData?.pitch ?? 0.0
        let roll = data.deviceMotionData?.roll ?? 0.0
        
        print("Yaw: \(yaw)")
        print("Pitch: \(pitch)")
        print("Roll: \(roll)")
        
        if abs(yaw - armfrontraisYaw) <= tolerance && abs(pitch - armfrontraisPitch) <= tolerance && abs(roll - armfrontraisRoll) <= tolerance {
            return "Arm vorne"
        } else if abs(yaw - armtopraiseYaw) <= tolerance && abs(pitch - armtopraisePitch) <= tolerance && abs(roll - armtopraiseRoll) <= tolerance {
            return "Arm oben"
        } else {
            return "Keine Erkennung"
        }
    }
}
