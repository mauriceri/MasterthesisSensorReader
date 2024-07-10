//
//  File.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 16.06.24.
//

import Foundation

struct AccelerometerData: Codable {
    let accelerationX: Double
    let accelerationY: Double
    let accelerationZ: Double
}

struct DeviceMotionData: Codable {
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

struct SensorData: Codable {
    var deviceMotionData: DeviceMotionData?
    var accelerometerData: AccelerometerData?
    
    func encodeIt() -> Data {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        
        return Data()
    }
    
    static func decodeIt(_ data: Data) -> SensorData {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(SensorData.self, from: data) {
            return decoded
        }
        
        return SensorData(deviceMotionData: nil, accelerometerData: nil)
    }
    
}

