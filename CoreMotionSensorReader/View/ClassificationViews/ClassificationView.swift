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
    
    
    var body: some View {
        List {
            Section(header: Text("Bewegung Apple Watch")) {
                if watchReciever.isUserMoving {
                    Text("Aktive Bewegung")
                } else {
                    Text("Keine Bewegung")
                }
            }
            
            Section(header: Text("Model ohne statische Haltung (Apple Watch)")) {
                if(!watchReciever.isUserMoving){
                    Text(watchReciever.armPositionThreshholdLabel)
                } else {
                    Text(watchReciever.reducedFeatureLabelAll)
                }
            }
            
            Section(header: Text("Model mit allen Labels (Apple Watch)")) {
                Text(watchReciever.fullFeatureLabelAll)
            }
            
            Section(header: Text("Haltungserkennung AirPods")) {
                Button("Verbindung erzwingen durch Ton") {
                    soundservice.playSound()
                }
                
                Button("Kalibriere AirPods") {
                    if airpodscontroller.latestUncalibratedData != nil {
                        airpodscontroller.calibrate(data: airpodscontroller.latestUncalibratedData!)
                    }
                }
                
    
                Text("Ort des Sensors: \(airpodscontroller.sensorlocation)")
                
                Text("Haltung: \(airpodscontroller.posturePrediction)")
            }
        }
    }
}


#Preview {
    ClassificationView(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
