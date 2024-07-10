//
//  AirpodsDataView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 17.06.24.
//

import SwiftUI

struct AirpodsDataView: View {
    @State private var airpodscontroller = AirpodsDataController()
    let soundservice = SoundService()
    
    
    var body: some View {
        
        VStack {
            List {
                Section(header: Text("Vorhersage")){
                    Text("\(airpodscontroller.prediction)")
                }
                
                Section(header: Text("Ort des Sensors")){
                    Text("\(airpodscontroller.sensorlocation)")
                }
                
                Section(header: Text("Tools")){
                    Button("Export"){
                        airpodscontroller.exportToCsv()
                    }
                    
                    Button("Aktuelle Daten löschen") {
                        airpodscontroller.clearArray()
                    }
                    
                    Button("Spiele Sound ab"){
                        soundservice.playSound()
                    }.clipShape(Capsule())
                }
                
                
                Section(header: Text("Ausrichtung AirPods")) {
                    Text("Pitch: \(airpodscontroller.lastSensorData?.pitch ?? 0.0)")
                    Text("Yaw: \(airpodscontroller.lastSensorData?.yaw ?? 0.0)")
                    Text("Roll: \(airpodscontroller.lastSensorData?.roll ?? 0.0)")
                }
                
                Section(header: Text("Rotationsrate")) {
                    Text("x: \(airpodscontroller.lastSensorData?.rotationRateX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.rotationRateY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.rotationRateZ ?? 0.0)")
                }
                
                Section(header: Text("Benutzerbeschleunigung")) {
                    Text("x: \(airpodscontroller.lastSensorData?.userAccelX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.userAccelY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.userAccelZ ?? 0.0)")
                }
                
                Section(header: Text("Schwerkraft")) {
                    Text("x: \(airpodscontroller.lastSensorData?.gravityAccelX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.gravityAccelY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.gravityAccelZ ?? 0.0)")
                }
                
            }
        }
    }
}

#Preview {
    AirpodsDataView()
}
