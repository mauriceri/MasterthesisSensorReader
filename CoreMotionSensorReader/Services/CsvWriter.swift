//
//  CsvWriter.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 09.07.24.
//

import Foundation
import CoreMotion


class CsvWriter {
    private let fileURL: URL
    
    init(fileName: String) {
        // Create a URL for the CSV file in the Documents directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentDirectory.appendingPathComponent(fileName)
        
        // Create the CSV file with headers if it doesn't exist
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try "timestamp,attitude_roll,attitude_pitch,attitude_yaw,gravity_x,gravity_y,gravity_z,rotationRate_x,rotationRate_y,rotationRate_z,userAcceleration_x,userAcceleration_y,userAcceleration_z\n".write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Error creating file: \(error)")
            }
        }
    }
    
    func writeCsv(data: [String: Any]) {
        // Convert Dictionary data to CSV string
        let csvString = self.csvString(from: data)
        
        // Append the CSV string to the file
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            if let data = csvString.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } catch {
            print("Error writing to file: \(error)")
        }
    }
    
    
    func writeMotionData(motionData: CMDeviceMotion) {
        let data: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "attitude_roll": motionData.attitude.roll,
            "attitude_pitch": motionData.attitude.pitch,
            "attitude_yaw": motionData.attitude.yaw,
            "gravity_x": motionData.gravity.x,
            "gravity_y": motionData.gravity.y,
            "gravity_z": motionData.gravity.z,
            "rotationRate_x": motionData.rotationRate.x,
            "rotationRate_y": motionData.rotationRate.y,
            "rotationRate_z": motionData.rotationRate.z,
            "userAcceleration_x": motionData.userAcceleration.x,
            "userAcceleration_y": motionData.userAcceleration.y,
            "userAcceleration_z": motionData.userAcceleration.z,
        ]
        writeCsv(data: data)
    }
    
    
    private func csvString(from data: [String: Any]) -> String {
        let timestamp = data["timestamp"] as? TimeInterval ?? 0.0
        let attitudeRoll = data["attitude_roll"] as? Double ?? 0.0
        let attitudePitch = data["attitude_pitch"] as? Double ?? 0.0
        let attitudeYaw = data["attitude_yaw"] as? Double ?? 0.0
        let gravityX = data["gravity_x"] as? Double ?? 0.0
        let gravityY = data["gravity_y"] as? Double ?? 0.0
        let gravityZ = data["gravity_z"] as? Double ?? 0.0
        let rotationRateX = data["rotationRate_x"] as? Double ?? 0.0
        let rotationRateY = data["rotationRate_y"] as? Double ?? 0.0
        let rotationRateZ = data["rotationRate_z"] as? Double ?? 0.0
        let userAccelerationX = data["userAcceleration_x"] as? Double ?? 0.0
        let userAccelerationY = data["userAcceleration_y"] as? Double ?? 0.0
        let userAccelerationZ = data["userAcceleration_z"] as? Double ?? 0.0
        
        return "\(timestamp),\(attitudeRoll),\(attitudePitch),\(attitudeYaw),\(gravityX),\(gravityY),\(gravityZ),\(rotationRateX),\(rotationRateY),\(rotationRateZ),\(userAccelerationX),\(userAccelerationY),\(userAccelerationZ)\n"
    }
}
