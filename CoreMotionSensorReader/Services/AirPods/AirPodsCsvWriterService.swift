//
//  AirPodsCsvWriterService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 22.06.24.
//

import Foundation

class AirPodsCsvWriterService {
    
    
    func exportCSV(from data: [AirPodsMotionData], to filename: String) -> Void {
        // CSV-Kopfzeile
        let header = "pitch,yaw,roll,rotationRateX,rotationRateY,rotationRateZ,userAccelX,userAccelY,userAccelZ,gravityAccelX,gravityAccelY,gravityAccelZ\n"
        
        // CSV-Inhalt
        var csvString = header
        for record in data {
            let line = "\(record.pitch),\(record.yaw),\(record.roll),\(record.rotationRateX),\(record.rotationRateY),\(record.rotationRateZ),\(record.userAccelX),\(record.userAccelY),\(record.userAccelZ),\(record.gravityAccelX),\(record.gravityAccelY),\(record.gravityAccelZ)\n"
            csvString += line
        }
        
        // Pfad zur Datei
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        // CSV-String in Datei schreiben
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            print("CSV-Datei erfolgreich exportiert nach \(path)")
        } catch {
            print("Fehler beim Exportieren der CSV-Datei: \(error)")
        }
    }
}
