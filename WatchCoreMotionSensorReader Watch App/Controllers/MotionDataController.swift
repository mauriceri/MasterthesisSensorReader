//
//  MotionDataViewModel.swift
//  WatchCoreMotionSensorReader Watch App
//
//  Created by Maurice Richter on 17.06.24.
//

import Foundation
import CoreMotion

@Observable
class MotionDataController {
    
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
    
    var samplingRate: Double = 0.0
    
    var sensorBuffer: [SensorData] = []
    var batchTimer: Timer?

    
    func getElapsedTime() -> TimeInterval {
        guard let first = sensorData.first, let last = sensorData.last else {
            return 0
        }
        return last.timestamp.timeIntervalSince(first.timestamp)
    }
    
    
    let sensorQueue = OperationQueue()
    
    func startReadingSensors() {
        self.currentSensorData.timestamp = Date()
        self.currentSensorData.elapsedTime = getElapsedTime()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1/60.1
            motionManager.startAccelerometerUpdates(to: sensorQueue) { [weak self] (data, error) in
                if let data = data {
                    self?.currentSensorData.accelerometerData = AccelerometerData(
                        accelerationX: data.acceleration.x,
                        accelerationY: data.acceleration.y,
                        accelerationZ: data.acceleration.z
                    )
                    //self?.updateSensorDataArray()
                    DispatchQueue.main.async {
                                   self?.updateSensorDataArray()
                               }
                }
            }
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/60.1
            motionManager.startDeviceMotionUpdates(to: sensorQueue) { [weak self] (data, error) in
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
                    
                    DispatchQueue.main.async {
                                   self?.updateSensorDataArray()
                               }
                    //self?.updateSensorDataArray()
                }
            }
        }
        
        
        updateSensorDataArray()
        startBatchTimer()

    }
    

    // Startet den Timer, um jede Sekunde einen Batch zu senden
    private func startBatchTimer() {
        batchTimer?.invalidate() // Falls bereits ein Timer läuft, stoppen
        batchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.sendSensorBatch()
        }
    }


    // Sendet den aktuellen Sensor-Buffer als Batch
    private func sendSensorBatch() {
        guard !sensorBuffer.isEmpty else { return }
        
        self.connectivity.sendSensorDataBatch(data: sensorBuffer) 
        print("Batch gesendet mit \(sensorBuffer.count) Einträgen")
        sensorBuffer.removeAll()
    }
    
 
    private func updateSensorDataArray() {
        guard currentSensorData.accelerometerData != nil && currentSensorData.deviceMotionData != nil else {
            return
        }
        
        sensorBuffer.append(currentSensorData) // Speichere Sensordaten im Buffer
        currentSensorData = SensorData() // Setze `currentSensorData` zurück
    }

    

    func stopReadingSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}


