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
    let rightYaw: Double = 0.7
    
    let upPitch: Double = 0.7
    let downPitch: Double = -0.7
    

    
    func predictViewingDirection(data: AirPodsMotionData) -> String {
        
        let yaw: Double = data.yaw
        let pitch: Double = data.pitch
        
        if (yaw <= leftYaw) {
            return "Rechts"
        } else if (yaw >= rightYaw) {
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
