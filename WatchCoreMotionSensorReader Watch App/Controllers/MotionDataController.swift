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
    
    var sensorBuffer: [SensorData] = [] // Buffer für Sensordaten
    var batchTimer: Timer?              // Timer für das Senden des Batches

    
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
            motionManager.accelerometerUpdateInterval = 1/60.0
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
            motionManager.deviceMotionUpdateInterval = 1/60.0
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
        batchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendSensorBatch()
        }
    }


    // Sendet den aktuellen Sensor-Buffer als Batch
    private func sendSensorBatch() {
        guard !sensorBuffer.isEmpty else { return } // Falls der Buffer leer ist, nichts senden
        
        self.connectivity.sendSensorDataBatch(data: sensorBuffer) // Sende Batch
        print("Batch gesendet mit \(sensorBuffer.count) Einträgen") // Debug-Print
        sensorBuffer.removeAll() // Buffer nach dem Senden leeren
    }
    
    /*
    private func sendSensorBatch() {
        guard !sensorBuffer.isEmpty else { return } // Falls der Buffer leer ist, nichts senden

        let batchSize = min(sensorBuffer.count, 60) // Maximal 60 Werte senden
        let batchToSend = Array(sensorBuffer.prefix(batchSize))
        
        self.connectivity.sendSensorDataBatch(data: batchToSend) // Sende Batch
        print("Batch gesendet mit \(batchToSend.count) Einträgen") // Debugging
        
        sensorBuffer.removeFirst(batchSize) // Entferne nur die gesendeten Werte
    }
     */
    
    
    private func updateSensorDataArray() {
        guard currentSensorData.accelerometerData != nil && currentSensorData.deviceMotionData != nil else {
            return
        }
        
        let now = Date()
        sensorBuffer.append(currentSensorData) // Speichere Sensordaten im Buffer
        

        currentSensorData = SensorData() // Setze `currentSensorData` zurück
    }
    
    /*
    func startReadingSensors() {
        
        self.currentSensorData.timestamp = Date()
        self.currentSensorData.elapsedTime = getElapsedTime()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60
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
            motionManager.deviceMotionUpdateInterval = 1.0 / 60
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
     */
    
    
    /*
    private func updateSensorDataArray() {
        guard currentSensorData.accelerometerData != nil && currentSensorData.deviceMotionData != nil else {
            return
        }
        self.lastSensorData = currentSensorData
        sensorData.append(currentSensorData)
        
        self.connectivity.sendSensorData(data: currentSensorData)
        currentSensorData = SensorData()
    }
     */
    
    
    func stopReadingSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}


