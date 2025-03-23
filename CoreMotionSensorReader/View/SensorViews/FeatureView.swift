//
//  FeatureView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 24.02.25.
//

import SwiftUI

struct FeatureView: View {
    
    @Bindable var watchReciever: WatchReciverController
    

    var body: some View {
        List {
            Text("rotationZ min: \(watchReciever.currentFeatureStruct?.rotationRateZ_filtered_min ?? 0.0)")
            Text("gravityAccelZ max: \(watchReciever.currentFeatureStruct?.gravityAccelZ_filtered_max ?? 0.0)")
            Text("pitch min: \(watchReciever.currentFeatureStruct?.pitch_filtered_min ?? 0.0)")
        }
       
    }
}

#Preview {
    FeatureView(watchReciever: WatchReciverController())
}
