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
            if(watchReciever.isUserMoving) {
                Text(watchReciever.reducedFeatureLabelAll)
            } else {
                Text("Keine Bewegung")
            }
        }
    }
}

#Preview {
    ClassificationView(watchReciever: WatchReciverController())
}
