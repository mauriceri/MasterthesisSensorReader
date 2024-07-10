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
            WatchSensorView()
                .tabItem { Label("Watch", systemImage:"watch.analog" ) }
            
            AirpodsDataView()
                .tabItem { Label("Airpods", systemImage: "airpodspro") }
            
            HealthDataView()
                .tabItem { Label("Gesundheitsdaten", systemImage: "heart.fill")}

        }
    }
}

#Preview {
    TabContentView()
        .environment(WatchReciverController())
}
