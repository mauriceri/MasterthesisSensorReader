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
        
        
        VStack {
        

       
                if let featureAllLabel = watchReciever.allLabelFeatures {
                    Text("pitch_min: \(String(format: "%.3f", featureAllLabel.pitch_min))")
                    Text("gravityAccelZ_max: \(String(format: "%.3f", featureAllLabel.gravityAccelZ_max))")
                    Text("gravityAccelY_max: \(String(format: "%.3f", featureAllLabel.gravityAccelY_max))")
                    Text("rotationRateZ_std: \(String(format: "%.3f", featureAllLabel.rotationRateZ_std))")
                    Text("gravityAccelZ_min: \(String(format: "%.3f", featureAllLabel.gravityAccelZ_min))")
                    Text("rotationRateZ_max: \(String(format: "%.3f", featureAllLabel.rotationRateZ_max))")
                    Text("accelerationY_max: \(String(format: "%.3f", featureAllLabel.accelerationY_max))")
                    Text("roll_min: \(String(format: "%.3f", featureAllLabel.roll_min))")
                    Text("roll_std: \(String(format: "%.3f", featureAllLabel.roll_std))")
                    Text("gravityAccelX_min: \(String(format: "%.3f", featureAllLabel.gravityAccelX_min))")
                } else {
                    Text("Keine Features vorhanden")
                }
       
        }
        
        
    }
    
}



#Preview {
    FeatureView(watchReciever: WatchReciverController())
}
