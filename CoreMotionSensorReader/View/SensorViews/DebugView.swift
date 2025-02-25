//
//  DebugView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 25.02.25.
//

import SwiftUI

struct DebugView: View {
    
    @Bindable var watchReciever: WatchReciverController
    @Bindable var airpodscontroller = AirpodsDataController()
    
    
    var body: some View {
        Section(header: Text("Apple Watch")) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Ausrichtung")
                        .font(.headline)
                    Text("Pitch: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                    Text("Yaw: \(watchReciever.lastSensorData?.deviceMotionData?.yaw ?? 0.0)")
                    Text("Roll: \(watchReciever.lastSensorData?.deviceMotionData?.pitch ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Benutzer Beschleunigung")
                        .font(.headline)
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.userAccelZ ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Schwerkraft Beschleunigung")
                        .font(.headline)
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.gravityAccelZ ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Rotationsrate")
                        .font(.headline)
                    Text("X: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.deviceMotionData?.rotationRateZ ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Beschleunigung")
                        .font(.headline)
                    Text("X: \(watchReciever.lastSensorData?.accelerometerData?.accelerationX ?? 0.0)")
                    Text("Y: \(watchReciever.lastSensorData?.accelerometerData?.accelerationY ?? 0.0)")
                    Text("Z: \(watchReciever.lastSensorData?.accelerometerData?.accelerationZ ?? 0.0)")
                }
            }
            .padding(.vertical)
        }
        
        
        if(airpodscontroller.isAvailable) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Ausrichtung")
                        .font(.headline)
                    Text("Pitch: \(airpodscontroller.lastSensorData?.pitch ?? 0.0)")
                    Text("Yaw: \(airpodscontroller.lastSensorData?.yaw ?? 0.0)")
                    Text("Roll: \(airpodscontroller.lastSensorData?.roll ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Rotationsrate")
                        .font(.headline)
                    Text("x: \(airpodscontroller.lastSensorData?.rotationRateX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.rotationRateY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.rotationRateZ ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Benutzerbeschleunigung")
                        .font(.headline)
                    Text("x: \(airpodscontroller.lastSensorData?.userAccelX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.userAccelY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.userAccelZ ?? 0.0)")
                }
                
                VStack(alignment: .leading) {
                    Text("Schwerkraft")
                        .font(.headline)
                    Text("x: \(airpodscontroller.lastSensorData?.gravityAccelX ?? 0.0)")
                    Text("y: \(airpodscontroller.lastSensorData?.gravityAccelY ?? 0.0)")
                    Text("z: \(airpodscontroller.lastSensorData?.gravityAccelZ ?? 0.0)")
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    DebugView(watchReciever: WatchReciverController())
}
