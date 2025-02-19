//
//  SensorView.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import SwiftUI

struct SensorView: View {
    
    @Environment(MotionDataController.self) private var sensorReader
    @StateObject private var workoutManager = WorkoutManager()

    @State var startedRunning: Bool = false

    @State private var showAlert = false
    
    let steps = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

    var body: some View {

        VStack {
            
            List {
                Section(header: Text("Sensor/Workout Steuerung")){
                    
                    if(startedRunning == false){
                        Button("Starte Workout/Sensoren") {
                            workoutManager.startWorkout()
                            sensorReader.startReadingSensors()
                            startedRunning = true
                            showAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    } else {
                        Button("Beende Workout/Sensorlesen") {
                            workoutManager.endWorkout()
                            sensorReader.stopReadingSensors()
                            startedRunning = false
                            showAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red) // Setzt die Button-Farbe auf Rot
                    }
                    
                }
                
                
                Text("Abtastrate: \(Int(sensorReader.sampleRate)) Hz")
                    .font(.headline)
                    .padding()
                
                Slider(
                    value: Binding(
                        get: {
                            Double(steps.firstIndex(of: Int(sensorReader.sampleRate)) ?? 0)
                        },
                        set: { newValue in
                            sensorReader.sampleRate = Double(steps[Int(newValue)])
                            self.sensorReader.stopReadingSensors()
                            self.sensorReader.startReadingSensors()
                        }
                    ),
                    in: 0...Double(steps.count - 1),
                    step: 1
                )
                .padding()
                
                Text("Einstellbare Abtastrate: 1, 10, 20, 30, 40, 50, 60")
                    .font(.footnote)
                    .padding()
                
                
                Section(header: Text("Ausrichtung")) {
                    Text("Pitch: \(sensorReader.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                    Text("Yaw: \(sensorReader.lastSensorData?.deviceMotionData?.yaw ?? 0.0)")
                    Text("Roll: \(sensorReader.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                }
                
                Section(header: Text("Benutzer Beschleunigung")) {
                    Text("X: \(sensorReader.lastSensorData?.deviceMotionData?.userAccelX ?? 0.0)")
                    Text("Y: \(sensorReader.lastSensorData?.deviceMotionData?.userAccelY ?? 0.0)")
                    Text("Z: \(sensorReader.lastSensorData?.deviceMotionData?.userAccelZ ?? 0.0)")
                }
                
                Section(header: Text("Schwerkraft Beschleunigung")) {
                    Text("X: \(sensorReader.lastSensorData?.deviceMotionData?.gravityAccelX ?? 0.0)")
                    Text("Y: \(sensorReader.lastSensorData?.deviceMotionData?.gravityAccelY ?? 0.0)")
                    Text("Z: \(sensorReader.lastSensorData?.deviceMotionData?.gravityAccelZ ?? 0.0)")
                }
                
                Section(header: Text("Rotationsrate")) {
                    Text("X: \(sensorReader.lastSensorData?.deviceMotionData?.rotationRateX ?? 0.0)")
                    Text("Y: \(sensorReader.lastSensorData?.deviceMotionData?.rotationRateY ?? 0.0)")
                    Text("Z: \(sensorReader.lastSensorData?.deviceMotionData?.rotationRateZ ?? 0.0)")
                }
                
                Section(header: Text("Beschleunigung")) {
                    Text("X: \(sensorReader.lastSensorData?.accelerometerData?.accelerationX ?? 0.0)")
                    Text("Y: \(sensorReader.lastSensorData?.accelerometerData?.accelerationY ?? 0.0)")
                    Text("Z: \(sensorReader.lastSensorData?.accelerometerData?.accelerationZ ?? 0.0)")
                }
            }
        }.onAppear() {
            //sensorReader.startReadingSensors()
            workoutManager.requestAuthorization()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Aktion bestätigt"),
                message: Text(startedRunning ? "Workout gestartet!" : "Workout beendet!"),
                dismissButton: .default(Text("OK")) {
                    showAlert = false // Setzt den Wert zurück
                }
            )
        }
        
    }
    
}

#Preview {
    SensorView()
        .environment(MotionDataController())
}
