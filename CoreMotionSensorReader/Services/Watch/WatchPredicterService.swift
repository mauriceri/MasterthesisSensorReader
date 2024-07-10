//
//  WatchPredicterService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 10.07.24.
//

import Foundation


class WatchPredicterService {
    let armUpGravityx: Double = -0.15
    let armUpGravityz: Double = -0.75
    let armUpRoll: Double = 0.00

    
    
    func predictMovement(motionData: SensorData) -> String {
        
        //let attitude_roll = (motionData["attitude_roll"] as! Double)
        
        let attitude_roll: Double = motionData.deviceMotionData!.roll
        let gravity_x: Double = motionData.deviceMotionData!.gravityAccelX
        let gravity_z: Double = motionData.deviceMotionData!.gravityAccelZ
        //let gravity_x = (motionData["gravity_x"] as! Double)
        //let gravity_z = motionData["gravity_z"] as! Double
        
        if (gravity_x >= armUpGravityx && gravity_z >= armUpGravityz && attitude_roll >= armUpRoll) {
            return "Arm unten"
        } else {
            return "Arm oben"
        }
    }
}
