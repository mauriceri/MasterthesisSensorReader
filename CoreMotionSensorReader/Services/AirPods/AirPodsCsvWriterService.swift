//
//  AirPodsCsvWriterService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 22.06.24.
//

import Foundation
class AirPodsCsvWriterService {
    
    func exportCSV(from data: [AirPodsMotionData], to filename: String) -> Void {
        let header = "timestamp,elapsedTime,pitch,yaw,roll,rotationRateX,rotationRateY,rotationRateZ,userAccelX,userAccelY,userAccelZ,gravityAccelX,gravityAccelY,gravityAccelZ\n"
        
        let dateFormatter = ISO8601DateFormatter()
        var csvString = header
        for record in data {
            let timestampString = dateFormatter.string(from: record.timestamp)
            let line = "\(timestampString),\(record.elapsedTime),\(record.pitch),\(record.yaw),\(record.roll),\(record.rotationRateX),\(record.rotationRateY),\(record.rotationRateZ),\(record.userAccelX),\(record.userAccelY),\(record.userAccelZ),\(record.gravityAccelX),\(record.gravityAccelY),\(record.gravityAccelZ)\n"
            csvString += line
        }
        
        let path = getUniqueFilePath(for: filename)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            print("CSV-Datei erfolgreich exportiert nach \(path)")
        } catch {
            print("Fehler beim Exportieren der CSV-Datei: \(error)")
        }
    }
    
    private func getUniqueFilePath(for filename: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileExtension = (filename as NSString).pathExtension
        let baseFilename = (filename as NSString).deletingPathExtension
        var filePath = directory.appendingPathComponent(filename)
        var fileIndex = 1
        
        while FileManager.default.fileExists(atPath: filePath.path) {
            let newFilename = "\(baseFilename)_\(fileIndex).\(fileExtension)"
            filePath = directory.appendingPathComponent(newFilename)
            fileIndex += 1
        }
        
        return filePath
    }
}
