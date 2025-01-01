//
//  WatchAirPodsSensorView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 27.12.24.
//

import SwiftUI

struct WatchAirPodsSensorView: View {
    
    @State private var watchReciever = WatchReciverController()
    @State private var airpodscontroller = AirpodsDataController()
    
    @State private var showingPopover = false
    
    let soundservice = SoundService()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Bewegungserkennung Apple Watch")) {
                    Text("Threshold: \(watchReciever.prediction)")
                    Text("Model: \(watchReciever.modelPrediction)")
                    
                    
                }
                
                if (airpodscontroller.isAvailable) {
                    Section(header: Text("Bewegungserkennung AirPods")){
                        Text("Threshold: \(airpodscontroller.prediction)")
                        Text("Model: \(airpodscontroller.modelPrediction)")
                    }
                }
                
               
                 
                Section(header: Text("Daten-Export (CSV)")) {
                    
                    if(watchReciever.isCollectingTrainData) {
                        Text("Die Daten werden gesammelt. Nach erfolgreichem Abschluss des Sammelns werden die Exportoptionen wieder sichtbar. Verbleibende Zeit: \(watchReciever.timerSeconds)")
                            .foregroundStyle(Color.red)
                            .font(.headline)
                            .padding()
                        
                        Button("Timer Abbrechen") {
                            watchReciever.stopAllTimers()
                            airpodscontroller.stopAllTimers()
                        }
                        
                        Spacer()
                        
                    } else {
                        Button("Sitzend Marschieren") {
                            watchReciever.startTimerAndExport(to: "watch_sit_march.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.startTimerAndExport(to: "airpods_sit_march.csv")
                            }
                        }
                        
                        Button("Arm nach vorne Heben") {
                            watchReciever.startTimerAndExport(to: "watch_arm_front_raise.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.startTimerAndExport(to: "airpods_arm_front_raise.csv")
                            }
                        }
                        
                        Button("Gewicht verlagern mit Arm") {
                            watchReciever.startTimerAndExport(to: "watch_weight_dist.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.startTimerAndExport(to: "airpods_weight_dist.csv")
                            }
                        }
                        
                        Button("Schnelle tiefe Schritte") {
                            watchReciever.startTimerAndExport(to: "watch_steps_deep_fast.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.startTimerAndExport(to: "airpods_steps_deep_fast.csv")
                            }
                        }
                        
                        Button("Knie kreisen") {
                            watchReciever.startTimerAndExport(to: "watch_knee_circles.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.startTimerAndExport(to: "airpods_knee_circles.csv")
                            }
                        }
                        
                        Spacer()
                        
                        Button("Alle Daten Exportieren") {
                            watchReciever.exportToCsv(to: "watch_all_data.csv")
                            
                            if(airpodscontroller.isAvailable) {
                                airpodscontroller.exportToCsv(to: "airpods_all_data.csv")
                            }
                            
                        }
                    }
                    
                    Text("Datenmenge Aufnahme: \(watchReciever.getTempArraySitze())")
                    Text("Datenmenge insgesamt: \(watchReciever.getArraySize())")
                
                    Text("Vergangene Zeit: \(String(format: "%.2f", watchReciever.getElapsedTime()))")
                    Button("Daten löschen") {
                        watchReciever.clearData()
                        airpodscontroller.clearArray()
                    }
                }
                
                
                Section(header: Text("Apple Watch")) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Ausrichtung")
                                .font(.headline)
                            Text("Pitch: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                            Text("Yaw: \(watchReciever.lastSensorData?.deviceMotionData?.yaw ?? 0.0)")
                            Text("Roll: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Benutzer Beschleunigung")
                                .font(.headline)
                            Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelX ?? 0.0)")
                            Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelY ?? 0.0)")
                            Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelZ ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Schwerkraft Beschleunigung")
                                .font(.headline)
                            Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelX ?? 0.0)")
                            Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelY ?? 0.0)")
                            Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelZ ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Rotationsrate")
                                .font(.headline)
                            Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateX ?? 0.0)")
                            Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateY ?? 0.0)")
                            Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateZ ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Beschleunigung")
                                .font(.headline)
                            Text("X: \(watchReciever.lastSensorData?.accelerometerData?.accelerationX ?? 0.0)")
                            Text("Y: \(watchReciever.lastSensorData?.accelerometerData?.accelerationY ?? 0.0)")
                            Text("Z: \(watchReciever.lastSensorData?.accelerometerData?.accelerationZ ?? 0.0)")
                        }
                    }
                    .padding(.vertical)
                }
                
                
                Section(header: Text("AirPods")) {
                    
                    
                    if(airpodscontroller.isAvailable) {
                        Section(header: Text("Bewegungserkennung")){
                            Text("Threshold: \(airpodscontroller.prediction)")
                            Text("Model: \(airpodscontroller.modelPrediction)")
                        }
                        
                        Section(header: Text("Ort des Sensors")){
                            Text("\(airpodscontroller.sensorlocation)")
                        }
                        
                        Section(header: Text("Tools")){
                            Button("Export"){
                                airpodscontroller.exportToCsv(to: "airpodstest.csv")
                            }
                            
                            Button("Aktuelle Daten löschen") {
                                airpodscontroller.clearArray()
                            }
                            
                        }
                        
                    } else {
                        Text("AirPods-Daten nicht vefügbar. Versuche den Sound abzuspielen für das erzwingen der Verbindung").foregroundStyle(Color.red)
                        Button("Spiele Sound ab"){
                            soundservice.playSound()
                        }.clipShape(Capsule())
                    }
                }
                
                
                if(airpodscontroller.isAvailable) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Ausrichtung")
                                .font(.headline)
                            Text("Pitch: \(airpodscontroller.lastSensorData?.pitch ?? 0.0)")
                            Text("Yaw: \(airpodscontroller.lastSensorData?.yaw ?? 0.0)")
                            Text("Roll: \(airpodscontroller.lastSensorData?.roll ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Rotationsrate")
                                .font(.headline)
                            Text("x: \(airpodscontroller.lastSensorData?.rotationRateX ?? 0.0)")
                            Text("y: \(airpodscontroller.lastSensorData?.rotationRateY ?? 0.0)")
                            Text("z: \(airpodscontroller.lastSensorData?.rotationRateZ ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Benutzerbeschleunigung")
                                .font(.headline)
                            Text("x: \(airpodscontroller.lastSensorData?.userAccelX ?? 0.0)")
                            Text("y: \(airpodscontroller.lastSensorData?.userAccelY ?? 0.0)")
                            Text("z: \(airpodscontroller.lastSensorData?.userAccelZ ?? 0.0)")
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Schwerkraft")
                                .font(.headline)
                            Text("x: \(airpodscontroller.lastSensorData?.gravityAccelX ?? 0.0)")
                            Text("y: \(airpodscontroller.lastSensorData?.gravityAccelY ?? 0.0)")
                            Text("z: \(airpodscontroller.lastSensorData?.gravityAccelZ ?? 0.0)")
                        }
                    }
                    .padding(.vertical)
                }
                
            }
            
            
        }
        
    }
}


#Preview {
    WatchAirPodsSensorView()
}
