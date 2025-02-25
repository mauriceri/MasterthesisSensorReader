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
            Text("Max: \(watchReciever.currentFeatureStruct?.maxValues.first ?? 0.0)")
            Text("Min: \(watchReciever.currentFeatureStruct?.minValues.first ?? 0.0)")
            Text("FFT Magnitudes: \(watchReciever.currentFeatureStruct?.fftMagnitudes.first ?? 0.0)")
            Text("Squared Values: \(watchReciever.currentFeatureStruct?.squaredValues.first ?? 0.0)")
        }
       
    }
}

#Preview {
    FeatureView(watchReciever: WatchReciverController())
}
