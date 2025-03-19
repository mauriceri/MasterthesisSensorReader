//
//  SensorFeatures.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation

struct SensorFeaturesData: Codable {
    let accelerationX_max: Double
    let accelerationX_min: Double
    let accelerationY_max: Double
    let accelerationY_std: Double
    let sumOfSquaresPitchYawRoll: Double
    let sumOfSquaresAccel: Double
    let accelerationX: Double
    let pitch: Double
}
