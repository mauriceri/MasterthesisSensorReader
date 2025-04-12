//
//  SwiftUIView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 20.03.25.
//

import SwiftUI
struct ClassificationView: View {
    @Bindable var watchReciever: WatchReciverController
    
    var body: some View {
        List {
            Section(header: Text("Bewegung")) {
                if watchReciever.isUserMoving {
                    Text(watchReciever.reducedFeatureLabelAll)
                } else {
                    Text("Keine Bewegung")
                }
            }
            
            Section(header: Text("Armposition")) {
                
                if(!watchReciever.isUserMoving){
                    Text(watchReciever.armPositionThreshholdLabel)
                } else {
                    Text("Aktive Bewegung")
                }
            }
            
            Section(header: Text("Alle Label")) {
                
                
            }
        }
    }
}


#Preview {
    ClassificationView(watchReciever: WatchReciverController())
}
