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
            Text("Acc_x min: \(watchReciever.currentFeatureStruct?.accelerationX_min ?? 0.0)")
            Text("Acc_x max: \(watchReciever.currentFeatureStruct?.accelerationX_max ?? 0.0)")
            Text("Acc_y max: \(watchReciever.currentFeatureStruct?.accelerationY_max ?? 0.0)")
            Text("Acc_y std: \(watchReciever.currentFeatureStruct?.accelerationY_std ?? 0.0)")
        }
       
    }
}

#Preview {
    FeatureView(watchReciever: WatchReciverController())
}
