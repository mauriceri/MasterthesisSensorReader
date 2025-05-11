//
//  File.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 20.03.25.
//

import Foundation

class UserMovementDetection {
    func calculateAccelerationMagnitude(from data: [SensorData]) -> Double {
        guard !data.isEmpty else { return 0 }
        
        var totalAcceleration: Double = 0
        for entry in data {
            if let motion = entry.deviceMotionData {
                let magnitude = sqrt(pow(motion.userAccelX, 2) +
                                     pow(motion.userAccelY, 2) +
                                     pow(motion.userAccelZ, 2))
                totalAcceleration += magnitude
            }
        }
        
        return totalAcceleration / Double(data.count)
    }

    func isActiveMovement(from data: [SensorData], threshhold: Double) -> Bool {
        let avgAcceleration = calculateAccelerationMagnitude(from: data)
        return avgAcceleration > threshhold
    }
}

