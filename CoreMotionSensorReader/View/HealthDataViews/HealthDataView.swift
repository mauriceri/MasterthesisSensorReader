//
//  HealthDataView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 10.07.24.
//

import SwiftUI

struct HealthDataView: View {
    
    @State var storedata = HealthDataManager()
    
    var body: some View {
        VStack {
            List {
                Text("Heute verbrannte kcal: \(storedata.caloriesBurnedToday)")
                Text("Ruhepuls: \(storedata.restingHearthRate)")
                Text("Heutige Schritte: \(storedata.stepCountToday)")
                Text("Laufdistanz heute: \(storedata.walkingDistance)")

            }
        }
    }
}

#Preview {
    HealthDataView()
}
