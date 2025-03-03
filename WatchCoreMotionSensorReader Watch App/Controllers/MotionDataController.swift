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
    
    private let sensorDataQueue = DispatchQueue(label: "de.sensorreader.watchapp.sensordata", attributes: .concurrent)
    
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
            motionManager.accelerometerUpdateInterval =  1.0 / 70.0
            motionManager.startAccelerometerUpdates(to: sensorQueue) { [weak self] (data, error) in
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
            motionManager.deviceMotionUpdateInterval = 1.0 / 70.0
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
                    
                 
                    self?.updateSensorDataArray()
                }
            }
        }
        
  
        
        updateSensorDataArray()
        startBatchTimer()

    }
    

    // Startet den Timer, um jede Sekunde einen Batch zu senden
    private func startBatchTimer() {
        batchTimer?.invalidate()
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
        
        let newSensorData = SensorData() // Create a new instance first

        /*
        sensorDataQueue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sensorBuffer.append(strongSelf.currentSensorData)
            strongSelf.lastSensorData = strongSelf.currentSensorData
            strongSelf.currentSensorData = newSensorData // Safely assign outside critical section
        }
         */
        
        currentSensorData.timestamp = Date()
   
        sensorBuffer.append(currentSensorData)
        //self.lastSensorData = currentSensorData
        //currentSensorData = SensorData()
    }

    

    func stopReadingSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}


