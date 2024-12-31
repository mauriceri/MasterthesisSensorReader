//
//  NavView.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import SwiftUI

struct TabNavView: View {
    var body: some View {
        TabView() {
            SensorView().tabItem { }.tag(1)
        }
    }
}

#Preview {
    TabNavView()
}
