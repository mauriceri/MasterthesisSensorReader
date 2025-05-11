//
//  TabContentView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.06.24.
//

import SwiftUI

struct TabContentView: View {
    var body: some View {
        
        @State var watchReciever = WatchReciverController()
        @State var airpodscontroller = AirpodsDataController()

        
        TabView {
            ClassificationView(watchReciever: watchReciever, airpodscontroller: airpodscontroller).tabItem {
                Label("Klassifizierungen", systemImage: "arrow.triangle.2.circlepath")
            }
            
            
            SensorSettings(watchReciever: watchReciever, airpodscontroller: airpodscontroller).tabItem { Label("Einstellungen", systemImage: "gearshape")}

            
            ExampleTherapy(watchReciever: watchReciever, airpodscontroller: airpodscontroller).tabItem { Label("Therapie", systemImage: "sun.max.fill")}
            
            
            WatchAirPodsSensorView(watchReciever: watchReciever, airpodscontroller: airpodscontroller)
                .tabItem { Label("Watch&AirPods", systemImage: "person.wave.2.fill")}
        
       
            
            
            InfoView().tabItem{
                Label("Info", systemImage: "info")}
            
    

        }
    }
}

#Preview {
    TabContentView()
        .environment(WatchReciverController())
        .environment(AirpodsDataController())
}
