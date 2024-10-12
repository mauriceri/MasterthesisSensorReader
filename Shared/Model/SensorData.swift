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
    
    var timestamp: Date
    var elapsedTime: TimeInterval
    
    var deviceMotionData: DeviceMotionData?
    var accelerometerData: AccelerometerData?
    
    init(timestamp: Date = Date(),
         elapsedTime: TimeInterval = 0.0,
         deviceMotionData: DeviceMotionData? = nil,
         accelerometerData: AccelerometerData? = nil) {
        self.timestamp = timestamp
        self.elapsedTime = elapsedTime
        self.deviceMotionData = deviceMotionData
        self.accelerometerData = accelerometerData
    }
    
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
        
        return SensorData(timestamp: Date(),elapsedTime: 0.0, deviceMotionData: nil, accelerometerData: nil)
    }
    
}

