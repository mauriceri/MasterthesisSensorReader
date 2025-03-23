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
        
        TabView {
            WatchAirPodsSensorView(watchReciever: watchReciever)
                .tabItem { Label("Watch&AirPods", systemImage: "person.wave.2.fill")}
            
            FeatureView(watchReciever: watchReciever).tabItem{
                Label("FeatureView", systemImage: "x.squareroot")}
            
            ClassificationView(watchReciever: watchReciever).tabItem {
                Label("Klassifizierungen", systemImage: "arrow.triangle.2.circlepath")
            }
            
            
            InfoView().tabItem{
                Label("Info", systemImage: "info")}
            
    

        }
    }
}

#Preview {
    TabContentView()
        .environment(WatchReciverController())
}
