//
//  WorkoutView.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import SwiftUI

struct WorkoutView: View {
    var body: some View {
        
        VStack {
            Button("Start Therapy") {
                TherapySessionDelegate.shared.startExtendedRuntimeSession()
            }
            Button("Stop Therapy") {
                TherapySessionDelegate.shared.stopExtendedRuntimeSession()
            }
        }
      
    }
}

#Preview {
    WorkoutView()
}
