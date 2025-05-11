//
//  SwiftUIView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 20.03.25.
//

import SwiftUI

struct ClassificationView: View {
    @Bindable var watchReciever: WatchReciverController
    @Bindable var airpodscontroller: AirpodsDataController
    
    let soundservice = SoundService()
    
    @State private var isCountingDown = false
    @State private var countdown = 3
    @State private var timer: Timer?
    @State var debugMode: Bool = false
    
    
    var body: some View {
        List {
            Section(header: Text("Bewegung Apple Watch (Magnitude)")) {
                if watchReciever.isUserMoving {
                    Text("Aktive Bewegung")
                } else {
                    Text("Keine Bewegung")
                }
            }
            
            
            
            Toggle(isOn: $watchReciever.isReducedRandomForestActive) {
                Text("Zeige Random Forest mit reduzierten Klassen")
            }
            
            if watchReciever.isReducedRandomForestActive {
                if(!watchReciever.isUserMoving){
                    Text(watchReciever.armPositionThreshholdLabel)
                } else {
                    Text(watchReciever.reducedRfFeatureLabelAll)
                }
            }
            
            
            Toggle(isOn: $watchReciever.isFullRandomForestActive) {
                Text("Zeige Random Forest mit allen Klassen")
            }
            
            if watchReciever.isFullRandomForestActive {
                Text(watchReciever.fullRfFeatureLabelAll)
            }

            
            Toggle(isOn: $watchReciever.isDecisionTreeActive) {
                Text("Zeige Decision Tree")
            }
            
            if watchReciever.isDecisionTreeActive {
                Text(watchReciever.decisionTreeLabelAll)
            }
            
            Toggle(isOn: $watchReciever.isSVMActive) {
                Text("Zeige SVM")
            }
            if watchReciever.isSVMActive {
                Text(watchReciever.svmLabelAll)
            }
            
            
            Toggle(isOn: $watchReciever.isKNNActive) {
                Text("Zeige KNN")
            }
            
            if watchReciever.isKNNActive {
                Text(watchReciever.knnLabelAll)
            }
            
            
          
            
            
            
            Section(header: Text("AirPods")) {
                Toggle(isOn: $airpodscontroller.isClassificationActive) {
                    Text("Zeige AirPods Klassifizierung")
                }
                
                if airpodscontroller.isClassificationActive {
                    Section(header: Text("Haltungserkennung AirPods")) {
                        Button("Verbindung erzwingen durch Ton") {
                            soundservice.playSound()
                        }
                        
                        Button("Kalibriere AirPods (Instant)") {
                            if airpodscontroller.latestUncalibratedData != nil {
                                airpodscontroller.calibrate(data: airpodscontroller.latestUncalibratedData!)
                            }
                        }
                        
                        Button("Kalibriere AirPods (Countdown)") {
                            startCountdown()
                        }
                        .disabled(isCountingDown)
                        
                        if isCountingDown {
                            Text("Starte in \(countdown)...")
                                .foregroundColor(.gray)
                                .padding(.top)
                            Spacer()
                        }
                        
                        
                        Text("Ort des Sensors: \(airpodscontroller.sensorlocation)")
                        
                        Text("Körperhaltung: \(airpodscontroller.posturePrediction)")
                        Text("Kopfposition: \(airpodscontroller.prediction)")
                    }
                }
            }
            
            Section(header: Text("Feature View")) {
                Toggle(isOn: $debugMode) {
                    Text("Debug Mode, Zeige Sensordaten an")
                }
                
                if debugMode {
                    FeatureView(watchReciever: watchReciever)
                }
            }
            
            
        }
        
      
    }
    
    
    func startCountdown() {
        countdown = 3
        isCountingDown = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { tempTimer in
            countdown -= 1
            if countdown == 0 {
                tempTimer.invalidate()
                isCountingDown = false
                
                if let data = airpodscontroller.latestUncalibratedData {
                    airpodscontroller.calibrate(data: data)
                }
                soundservice.playSound()
            }
        }
    }
}


#Preview {
    ClassificationView(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
