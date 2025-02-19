//
//  WatchPredicterService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 10.07.24.
//

import Foundation
import CoreML


class WatchPredicterService {
    let armUpGravityx: Double = -0.15
    let armUpGravityz: Double = -0.75
    let armUpRoll: Double = 0.00
    
    let movementPrediction = try? MovementPrediction(configuration: .init())
    let marchingPrediction = try? MarchingClassifier(configuration: .init())
    
    
    
    
    func predictMovement(motionData: SensorData) -> String {
        
        //let attitude_roll = (motionData["attitude_roll"] as! Double)
        
        guard motionData.deviceMotionData != nil else {
               print("Device motion data ist nil")
               return "Unbekannt"
           }
        
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
    
    
    
    func testPred(motionData: SensorData) -> String {
        
        guard motionData.deviceMotionData != nil else {
               print("Device motion data ist nil")
               return "Unbekannt"
           }
        
        do {
            if let prediction = try movementPrediction?.prediction(rotationRateX: motionData.deviceMotionData!.rotationRateX,
                                                                   rotationRateY: motionData.deviceMotionData!.rotationRateY,
                                                                   rotationRateZ: motionData.deviceMotionData!.rotationRateZ,
                                                                   userAccelX: motionData.deviceMotionData!.userAccelX,
                                                                   userAccelY: motionData.deviceMotionData!.userAccelY,
                                                                   userAccelZ: motionData.deviceMotionData!.userAccelZ,
                                                                   gravityAccelX: motionData.deviceMotionData!.gravityAccelX,
                                                                   gravityAccelY: motionData.deviceMotionData!.gravityAccelY,
                                                                   gravityAccelZ: motionData.deviceMotionData!.gravityAccelZ,
                                                                   accelerationX: motionData.accelerometerData!.accelerationX,
                                                                   accelerationY: motionData.accelerometerData!.accelerationY,
                                                                   accelerationZ: motionData.accelerometerData!.accelerationZ) {
                
                
                let march: Double? = prediction.march["march"]
                if (march! > 0.7) {
                    return "Marschieren"
                } else {
                    return "Sitzen"
                }
                
            }
        } catch {
            print("error")
        }
        
        return "-"
    }
    
    
    func marchingPred(motionData: SensorData) -> String {
        
        
        return "-"

    }
    
    func collectValuesIntoMultiArray(input: Double) -> [[Double]] {
        var multiArray: [[Double]] = []

        for _ in 0..<100 {
            var row: [Double] = []
            for _ in 0..<1 {                
                row.append(input)
            }
            multiArray.append(row)
        }

        return multiArray
    }

    
    
    
}
