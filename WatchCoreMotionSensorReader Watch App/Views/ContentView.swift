//
//  ContentView.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 15.06.24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sensorReader = MotionDataViewModel()

    var body: some View {
        TabNavView()
            .environment(sensorReader)
    }
}

#Preview {
    ContentView()
}
