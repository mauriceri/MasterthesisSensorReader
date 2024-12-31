//
//  ContentView.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 15.06.24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sensorReader = MotionDataController()
    @StateObject var workoutManager = WorkoutManager()

    var body: some View {
        TabNavView()
            .environment(sensorReader)
            .environmentObject(workoutManager)
    }
}

#Preview {
    ContentView()
}
