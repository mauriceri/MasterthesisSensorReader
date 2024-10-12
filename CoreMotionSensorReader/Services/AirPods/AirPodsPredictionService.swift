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
    
    
    let movementPrediction = try? AirPodsPrediction(configuration: .init())


    
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
    
    func airpodsPrediction(motionData: CMDeviceMotion) -> String {
        
        do {
            if let prediction = try movementPrediction?.prediction(
                pitch: motionData.attitude.pitch,
                yaw: motionData.attitude.yaw,
                roll: motionData.attitude.roll,
                rotationRateX: motionData.rotationRate.x,
                rotationRateY: motionData.rotationRate.y,
                rotationRateZ: motionData.rotationRate.z,
                userAccelX: motionData.userAcceleration.x,
                userAccelY: motionData.userAcceleration.y,
                userAccelZ: motionData.userAcceleration.z,
                gravityAccelX: motionData.gravity.x,
                gravityAccelY: motionData.gravity.y,
                gravityAccelZ: motionData.gravity.z) {
                       
                
                
                let bent: Double? = prediction.bent["bent"]
                if (bent! > 0.6) {
                    return "Nicht gerade"
                } else {
                    return "Gerade Haltung"
                }
                
            }
        } catch {
            print("Error bei Airpods Prediction")
        }
        
        
        return "-"
    }
}
