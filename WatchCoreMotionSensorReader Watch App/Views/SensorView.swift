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
            
            if(startedRunning == false){
                Button("Starte Workout/Sensoren") {
                    workoutManager.startWorkout()
                    sensorReader.startReadingSensors()
                    startedRunning = true
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
               
        
         
            } else {
                Button("Beende Workout/Sensor") {
                    workoutManager.endWorkout()
                    sensorReader.stopReadingSensors()
                    startedRunning = false
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            
            
            
        }.onAppear() {
            workoutManager.requestAuthorization()
        }
    }
    
}

#Preview {
    SensorView()
        .environment(MotionDataController())
}
