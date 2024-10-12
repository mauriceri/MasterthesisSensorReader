//
//  CsvWriter.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 09.07.24.
//

import Foundation
import CoreMotion


class WatchCsvWriter {
    
    func exportCSV(from data: [SensorData], to filename: String) {
        // CSV-Kopfzeile
        let header = "timestamp,elapsed,pitch,yaw,roll,rotationRateX,rotationRateY,rotationRateZ,userAccelX,userAccelY,userAccelZ,gravityAccelX,gravityAccelY,gravityAccelZ,accelerationX,accelerationY,accelerationZ\n"
        
        // CSV-Inhalt
        var csvString = header
        let dateFormatter = ISO8601DateFormatter()
        
        for record in data {
            
            print(record.elapsedTime)
            var line = ""
            line += "\(dateFormatter.string(from: record.timestamp)),\(record.elapsedTime),"
            if let deviceMotion = record.deviceMotionData {
                line += "\(deviceMotion.pitch),\(deviceMotion.yaw),\(deviceMotion.roll),"
                line += "\(deviceMotion.rotationRateX),\(deviceMotion.rotationRateY),\(deviceMotion.rotationRateZ),"
                line += "\(deviceMotion.userAccelX),\(deviceMotion.userAccelY),\(deviceMotion.userAccelZ),"
                line += "\(deviceMotion.gravityAccelX),\(deviceMotion.gravityAccelY),\(deviceMotion.gravityAccelZ),"
            } else {
                line += ",,,,,,,,,,,,,"
            }
            
            if let accelerometer = record.accelerometerData {
                line += "\(accelerometer.accelerationX),\(accelerometer.accelerationY),\(accelerometer.accelerationZ)"
            } else {
                line += ",,"
            }
            
            line += "\n"
            csvString += line
        }
        
        // Pfad zur Datei, mit Überprüfung, ob eine Datei mit demselben Namen existiert
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
