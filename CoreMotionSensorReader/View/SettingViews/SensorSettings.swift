//
//  SensorSettings.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 11.05.25.
//

import SwiftUI

struct SensorSettings: View {
    
    @Bindable var watchReciever: WatchReciverController
    @Bindable var airpodscontroller: AirpodsDataController
    
    @State private var isEditing = false
    @State private var speed = 0.2
    
    @State private var isCountingDown = false
    @State private var countdown = 3
    @State private var calibrateTimer: Timer?
    
    let soundservice = SoundService()
    
    
    var body: some View {
        VStack {
            
            List {
                
                Section(header: Text("AirPods Verbindung")) {
                    Button("Verbindung erzwingen durch Ton") {
                        soundservice.playSound()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    
                }
                
                Section(header: Text("AirPods Kalibrierung")) {
                    Button("Kalibriere AirPods (Countdown)") {
                        startCountdown()
                    }
                    .disabled(isCountingDown)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    
                    if isCountingDown {
                        Text("Kalibrierung in \(countdown)...")
                            .foregroundColor(.gray)
                            .font(.system(size: 24, weight: .bold))
                            .padding(.top)
                        Spacer()
                    }
                    
                    Text("Ausrichtung: \(airpodscontroller.prediction)")
                }
                
                Section (header: Text("Watch Therapie Audio-Feedback")) {
                    Toggle(isOn: $watchReciever.isAudioFeedbackActive) {
                        Text("Audiofeedback aktiv")
                    }
                }
                
                
                Section(header: Text("Haltungsempfindlichkeit (AirPods)")) {
                    Slider(
                        value: $airpodscontroller.postureSensititvy,
                        in: 0...1,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    Text("\(airpodscontroller.postureSensititvy)")
                        .foregroundColor(isEditing ? .red : .blue)
                    
                    Text(airpodscontroller.posturePrediction)
                }
                
                Section(header: Text("Bewegungsempfindlichkeit (Watch)")) {
                    Slider(
                        value: $watchReciever.activeMovingThreshhold,
                        in: 0...2,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    Text("\(watchReciever.activeMovingThreshhold)")
                        .foregroundColor(isEditing ? .red : .blue)
                    Text(watchReciever.isUserMovingInformation)
                }
                
            
                
            }
            
        }
    }
    
    func startCountdown() {
        countdown = 3
        isCountingDown = true
        
        calibrateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { tempTimer in
            countdown -= 1
            if countdown == 0 {
                tempTimer.invalidate()
                isCountingDown = false
                
                if let data = airpodscontroller.latestUncalibratedData {
                    airpodscontroller.calibrate(data: data)
                }
                soundservice.playCalibrated()
            }
        }
    }
}

#Preview {
    SensorSettings(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
