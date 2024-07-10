//
//  MotionDataViewModel.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import Foundation
import CoreMotion

@Observable
class MotionDataViewModel {
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let connectivity = ConnectivityService()
    
    var sensorData: [SensorData] = []
    var lastSensorData: SensorData?

    private var currentSensorData = SensorData()
        
    var sampleRate = 60.0
    
    var timer: Timer?
    
    var isUpdating = false
 
    var sensorReaderIsUpdating = false
    

    
    func startReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / sampleRate
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                if let data = data {
                    self?.currentSensorData.accelerometerData = AccelerometerData(
                        accelerationX: data.acceleration.x,
                        accelerationY: data.acceleration.y,
                        accelerationZ: data.acceleration.z
                    )
                    self?.updateSensorDataArray()
                }
            }
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                if let data = data {
                    self?.currentSensorData.deviceMotionData = DeviceMotionData(
                        pitch: data.attitude.pitch,
                        yaw: data.attitude.yaw,
                        roll: data.attitude.roll,
                        rotationRateX: data.rotationRate.x,
                        rotationRateY: data.rotationRate.y,
                        rotationRateZ: data.rotationRate.z,
                        userAccelX: data.userAcceleration.x,
                        userAccelY: data.userAcceleration.y,
                        userAccelZ: data.userAcceleration.z,
                        gravityAccelX: data.gravity.x,
                        gravityAccelY: data.gravity.y,
                        gravityAccelZ: data.gravity.z
                    )
                    self?.updateSensorDataArray()
                }
            }
        }
        updateSensorDataArray()
    }
    
    private func updateSensorDataArray() {
        guard currentSensorData.accelerometerData != nil && currentSensorData.deviceMotionData != nil else {
            return
        }
        self.lastSensorData = currentSensorData
        sensorData.append(currentSensorData)
        
        self.connectivity.sendSensorData(data: currentSensorData)
        currentSensorData = SensorData()
    }
    
    func stopReadingSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}


