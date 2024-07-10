//
//  BatchedSensorData.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 16.06.24.
//

import Foundation
import CoreMotion


struct AccelerometerSnapshot: Codable {
    let timestamp: TimeInterval
    let accelerationX: Double
    let accelerationY: Double
    let accelerationZ: Double
}

struct GyroscopeSnapshot: Codable {
    let timestamp: TimeInterval
    let rotationX: Double
    let rotationY: Double
    let rotationZ: Double
}

struct MotionData: Codable {
    let accelerometerSnapshots: [AccelerometerSnapshot]
    let gyroscopeSnapshots: [GyroscopeSnapshot]
}

struct MotionDataChunk: Codable {
    let date: Date
    let data: MotionData
    
    init(date: Date, accelerometerData: [CMAccelerometerData], gyroscopeData: [CMDeviceMotion]) {
        self.date = date
        
        let accSnapshots = accelerometerData.map { data in
            AccelerometerSnapshot(timestamp: data.timestamp, accelerationX: data.acceleration.x, accelerationY: data.acceleration.y, accelerationZ: data.acceleration.z)
        }
        
        let gyrSnapshots = gyroscopeData.map { data in
            GyroscopeSnapshot(timestamp: data.timestamp, rotationX: data.rotationRate.x, rotationY: data.rotationRate.y, rotationZ: data.rotationRate.z)
        }
        
        self.data = MotionData(accelerometerSnapshots: accSnapshots, gyroscopeSnapshots: gyrSnapshots)
    }
    
    func encodeIt() -> Data {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        
        return Data()
    }
    
    static func decodeIt(_ data: Data) -> MotionDataChunk {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(MotionDataChunk.self, from: data) {
            return decoded
        }
        
        return MotionDataChunk(date: Date(), accelerometerData: [], gyroscopeData: [])
    }
    
    func createAcceletometerDataCSV() -> String {
        data.accelerometerSnapshots.reduce("") { partialResult, snapshot in
            partialResult + "\(snapshot.timestamp),\(snapshot.accelerationX),\(snapshot.accelerationY),\(snapshot.accelerationZ)\n"
        }
    }
    
    func createGyroscopeDataCSV() -> String {
        data.gyroscopeSnapshots.reduce("") { partialResult, snapshot in
            partialResult + "\(snapshot.timestamp),\(snapshot.rotationX),\(snapshot.rotationY),\(snapshot.rotationZ)\n"
        }
    }
}
