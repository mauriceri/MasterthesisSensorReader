//
//  WatchSensorView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 17.06.24.
//

import SwiftUI

struct WatchSensorView: View {
    
    @State private var watchReciever = WatchReciverController()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Vorhersagen")) {
                    Text("Threshold: \(watchReciever.prediction)")
                    Text("Model: \(watchReciever.modelPrediction)")
                }
                
                Section(header: Text("CSV-Export")) {
                    Button("CSV Export") {
                        watchReciever.exportToCsv()
                    }
                    
                    Text("Datenmenge: \(watchReciever.getArraySize())")
                    Text("Vergangene Zeit: \(String(format: "%.2f", watchReciever.getElapsedTime()))")
                    Button("Daten löschen") {
                        watchReciever.clearData()
                    }
                }
                
                
                
                Section(header: Text("Ausrichtung")) {
                    Text("Pitch: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                    Text("Yaw: \(watchReciever.lastSensorData?.deviceMotionData?.yaw ?? 0.0)")
                    Text("Roll: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                }
                
                Section(header: Text("Benutzer Beschleunigung")) {
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelZ ?? 0.0)")
                }
                
                Section(header: Text("Schwerkraft Beschleunigung")) {
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelZ ?? 0.0)")
                }
                
                Section(header: Text("Rotationsrate")) {
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateZ ?? 0.0)")
                }
                
                Section(header: Text("Beschleunigung")) {
                    Text("X: \(watchReciever.lastSensorData?.accelerometerData?.accelerationX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.accelerometerData?.accelerationY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.accelerometerData?.accelerationZ ?? 0.0)")
                }
            }
            
        }
    }
}

#Preview {
    WatchSensorView()
        .environment(WatchReciverController())
    
}
