//
//  SensorFeatures.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation

struct SensorFeatures: Codable {
    let minValues: [Double]
    let maxValues: [Double]
    let squaredValues: [Double]
    let fftMagnitudes: [Double]
}
