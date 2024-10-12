//
//  AirPodsSensorData.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.06.24.
//

import Foundation

struct AirPodsMotionData: Identifiable {
    
    let id = UUID()
    
    let timestamp: Date
    let elapsedTime: TimeInterval
    
    let pitch: Double
    let yaw: Double
    let roll: Double
    
    let rotationRateX: Double
    let rotationRateY: Double
    let rotationRateZ: Double
    
    let userAccelX: Double
    let userAccelY: Double
    let userAccelZ: Double
    
    let gravityAccelX: Double
    let gravityAccelY: Double
    let gravityAccelZ: Double
}
