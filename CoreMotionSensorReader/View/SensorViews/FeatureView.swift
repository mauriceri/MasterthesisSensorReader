//
//  FeatureView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 24.02.25.
//

import SwiftUI

struct FeatureView: View {
    
    @Bindable var watchReciever: WatchReciverController
    @Bindable var airpodscontroller: AirpodsDataController
    
    
    
    var body: some View {
        
        
        List {
            Section(header: Text("Features für 4 Label Model")) {
                if let featureReducedLabel = watchReciever.reducedLabelFeatures {
                    Text("rotationRateZ_std: \(String(format: "%.3f", featureReducedLabel.rotationRateZ_std))")
                    Text("rotationRateZ_max: \(String(format: "%.3f", featureReducedLabel.rotationRateZ_max))")
                    Text("accelerationY_max: \(String(format: "%.3f", featureReducedLabel.accelerationY_max))")
                    Text("rotationRateZ_min: \(String(format: "%.3f", featureReducedLabel.rotationRateZ_min))")
                    Text("gravityAccelY_max: \(String(format: "%.3f", featureReducedLabel.gravityAccelY_max))")
                    Text("userAccelY_std: \(String(format: "%.3f", featureReducedLabel.userAccelY_std))")
                    Text("roll_min: \(String(format: "%.3f", featureReducedLabel.roll_min))")
                    Text("pitch_min: \(String(format: "%.3f", featureReducedLabel.pitch_min))")
                    Text("gravityAccelX_min: \(String(format: "%.3f", featureReducedLabel.gravityAccelX_min))")
                    Text("gravityAccelSquaredVarCoeff: \(String(format: "%.3f", featureReducedLabel.gravityAccelSquaredVarCoeff))")
                } else {
                    Text("Keine features vorhanden")
                }
            }
            
            Section(header: Text("Features für 6 Label Model")) {
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
    
}



#Preview {
    FeatureView(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
