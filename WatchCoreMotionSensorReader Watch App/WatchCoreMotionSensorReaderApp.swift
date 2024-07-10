//
//  WatchCoreMotionSensorReaderApp.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 15.06.24.
//

import SwiftUI

@main
struct WatchCoreMotionSensorReader_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor private var therapySessionDelegate: TherapySessionDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
