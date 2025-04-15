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
            
            
            FeatureView(watchReciever: watchReciever, airpodscontroller: airpodscontroller).tabItem{
                Label("FeatureView", systemImage: "x.squareroot")}
            
            
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
