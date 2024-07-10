//
//  AirPodsPredictionService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 22.06.24.
//

import Foundation
import CoreMotion

class AirPodsPredictionService {
    let leftYaw: Double = -0.7
    let rigtYaw: Double = 0.7
    
    let upPitch: Double = 0.7
    let downPitch: Double = -0.7

    
    func predictViewingDirection(data: CMDeviceMotion) -> String {
        
        let yaw: Double = data.attitude.yaw
        let pitch: Double = data.attitude.pitch
        
        if (yaw <= leftYaw) {
            return "Rechts"
        } else if (yaw >= rigtYaw) {
            return "Links"
        } else if (pitch >= upPitch) {
            return "Oben"
        } else if (pitch <= downPitch) {
            return "Unten"
        } else {
            return "Gerade"
        }
        
    }
}
