//
//  TabContentView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.06.24.
//

import SwiftUI

struct TabContentView: View {
    var body: some View {
        TabView {
            WatchAirPodsSensorView()
                .tabItem { Label("Watch&AirPods", systemImage: "person.wave.2.fill")}
            
            InfoView().tabItem{
                Label("Info", systemImage: "info")}
            
            /*
            HealthDataView().tabItem {
                Label("Health Data", systemImage: "heart.fill")
            }
             */

        }
    }
}

#Preview {
    TabContentView()
        .environment(WatchReciverController())
}
