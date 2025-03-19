import Foundation
import CoreMotion

@Observable
class MotionDataController {
    private let motionManager = CMMotionManager()
    private let sensorDataQueue = DispatchQueue(label: "de.sensorreader.watchapp.sensordata", attributes: .concurrent)
    private let sensorQueue = OperationQueue()
    
    private let connectivity = ConnectivityService()
    
    private var sensorBuffer: [SensorData] = []
    private let maxBufferSize = 500 
    
    private var currentSensorData = SensorData()
    private var batchTimer: Timer?
    
    var lastSensorData: SensorData?
    
    var sampleRate = 65.0
    
    func startReadingSensors() {
        currentSensorData.timestamp = Date()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / sampleRate
            motionManager.startAccelerometerUpdates(to: sensorQueue) { [weak self] (data, error) in
                autoreleasepool {
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
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate
            motionManager.startDeviceMotionUpdates(to: sensorQueue) { [weak self] (data, error) in
                autoreleasepool {
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
        }
        
        startBatchTimer()
    }
    
    private func startBatchTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendSensorBatch()
        }
    }
    
    private func sendSensorBatch() {
        guard !sensorBuffer.isEmpty else { return }
        
        sensorDataQueue.async(flags: .barrier) {
            self.connectivity.sendSensorDataBatch(data: self.sensorBuffer)
            print("Batch gesendet mit \(self.sensorBuffer.count) Einträgen")
            self.sensorBuffer.removeAll()
        }
    }
    
    private func updateSensorDataArray() {
        guard currentSensorData.accelerometerData != nil, currentSensorData.deviceMotionData != nil else {
            return
        }
        
        let newSensorData = currentSensorData
        
        sensorDataQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.sensorBuffer.append(newSensorData)
            
            if self.sensorBuffer.count > self.maxBufferSize {
                self.sensorBuffer.removeFirst(self.sensorBuffer.count - self.maxBufferSize)
            }
        }
        
        currentSensorData = SensorData()
    }
    
    func stopReadingSensors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        batchTimer?.invalidate()
    }
}
