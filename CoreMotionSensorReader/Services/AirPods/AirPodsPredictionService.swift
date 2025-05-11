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
    
    let leftTiltRoll: Double = 0.5
    let rightTitltRoll: Double = -0.5

    let downleftPitch: Double = -0.4
    let downleftYaw: Double = 0.4
    
    let downrightPitch: Double = -0.4
    let downrightYaw: Double = -0.4
    
    let upleftPitch: Double = 0.4
    let upleftYaw: Double = -0.4
    
    let uprightPitch: Double = 0.4
    let uprighttYaw: Double = 0.4
    
    func predictViewingDirection(data: AirPodsMotionData) -> String {
        
        let yaw: Double = data.yaw
        let pitch: Double = data.pitch
        let roll: Double = data.roll
    
        
        if (yaw <= leftYaw) {
            return "Rechts"
        } else if (yaw >= rightYaw) {
            return "Links"
        } else if (pitch >= upPitch) {
            return "Oben"
        } else if (pitch <= downPitch) {
            return "Unten"
        } else if (roll >= leftTiltRoll) {
            return "Rechts geneigt"
        } else if (roll <= rightTitltRoll) {
            return "Links geneigt"
            
        } else if ((yaw >= downleftYaw) && (pitch <= downleftPitch)) {
            return "Unten links"
        } else if ((yaw <= downrightYaw) && (pitch <= downrightPitch)) {
            return "Unten rechts"
        } else if ((yaw <= upleftYaw) && (pitch >= upleftPitch)) {
            return "Oben rechts"
        } else if ((yaw >= uprighttYaw) && (pitch >= uprightPitch)) {
            return "Oben links"
        }
        
        else {
            return "Gerade"
        }
        
    }
    
    func predicitPosture(data: AirPodsMotionData, sens: Double) -> String {
        let yaw: Double = data.yaw
        let pitch: Double = data.pitch
        let roll = data.roll
        
        if (abs(yaw) <= sens) && (abs(pitch) <= sens) && (abs(roll) <= sens) {
            return "Gerade"
        } else {
            return "Nicht gerade"
        }
    }
}
