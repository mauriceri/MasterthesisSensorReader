//
//  AirpodsDataViewModel.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 17.06.24.
//

import Foundation
import CoreMotion

@Observable
class AirpodsDataController: NSObject, CMHeadphoneMotionManagerDelegate {
    
    let predictionService = AirPodsPredictionService()
    let csvWriter = AirPodsCsvWriterService()
    
    let queue = OperationQueue()
    var motionManager = CMHeadphoneMotionManager()
    
    var data: MotionData?
    
    var sensorData: [AirPodsMotionData] = []
    var lastSensorData: AirPodsMotionData?
    
    var tempData = [AirPodsMotionData]()
    private var timer: Timer?
    private var countTimer: Timer? = nil
    var timerSeconds: Int = 60
    var isCollectingTrainData: Bool = false
    var isCountTimerRunning: Bool = false
    
    
    var prediction: String = "-"
    var modelPrediction: String = "-"
    var sensorlocation: String = "-"
    
    
    var isCalibrated: Bool = false
    
    var pitchBias: Double = 0.0
    var yawBias: Double = 0.0
    var rollBias: Double = 0.0
    var rotationRateXBias: Double = 0.0
    var rotationRateYBias: Double = 0.0
    var rotationRateZBias: Double = 0.0
    var userAccelXBias: Double = 0.0
    var userAccelYBias: Double = 0.0
    var userAccelZBias: Double = 0.0
    var gravityAccelXBias: Double = 0.0
    var gravityAccelYBias: Double = 0.0
    var gravityAccelZBias: Double = 0.0
    
    var latestUncalibratedData: AirPodsMotionData?
 
    
    var isAvailable: Bool {
        return motionManager.isDeviceMotionAvailable
    }
    
    
    
    override init() {
        super.init()
        motionManager.delegate = self
        startHeadphoneData()
    }
    
    func exportToCsv(to fileName: String) -> Void {
        csvWriter.exportCSV(from: sensorData, to: fileName)
    }
    
    
    func exportToCsv(data: [AirPodsMotionData], to fileName: String) {
        csvWriter.exportCSV(from: data, to: fileName)
    }
    
    func clearArray() -> Void {
        self.sensorData.removeAll()
    }
    
    func getSensorDataAmount() -> Int {
        return self.sensorData.count
    }
    
    func resetSensorData() -> Void {
        self.sensorData.removeAll()
    }
    
 
    func getElapsedTime() -> TimeInterval {
        guard let first = tempData.first, let last = tempData.last else {
            return 0
        }
        return last.timestamp.timeIntervalSince(first.timestamp)
    }
    
    func startTimerAndExport(to fileName: String) {
        self.tempData.removeAll()
        self.isCollectingTrainData = true
        self.isCountTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isCollectingTrainData = false
            self.exportToCsv(data: self.tempData, to: fileName)
            self.tempData.removeAll()
        }
        
        countTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timerSeconds > 0 {
                self.timerSeconds -= 1
            } else {
                self.countTimer?.invalidate()
                self.countTimer = nil
                self.timerSeconds = 30
                self.isCountTimerRunning = false
            }
        }
    }
    
    func stopAllTimers() -> Void {
        self.isCollectingTrainData = false
        self.isCountTimerRunning = false
        self.timer?.invalidate()
        self.timer = nil
        self.countTimer?.invalidate()
        self.countTimer = nil
        self.timerSeconds = 60
    }
    
    
    
    func startHeadphoneData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
                
                guard let motion else {
                    print("keine motion")
                    return
                }
                
                let newData = AirPodsMotionData(
                    timestamp: Date(),
                    elapsedTime: self.getElapsedTime(),
                    pitch: motion.attitude.pitch - self.pitchBias,
                    yaw: motion.attitude.yaw - self.yawBias,
                    roll: motion.attitude.roll - self.rollBias,
                    rotationRateX: motion.rotationRate.x - self.rotationRateXBias,
                    rotationRateY: motion.rotationRate.y - self.rotationRateYBias,
                    rotationRateZ: motion.rotationRate.z - self.rotationRateZBias,
                    userAccelX: motion.userAcceleration.x - self.userAccelXBias,
                    userAccelY: motion.userAcceleration.y - self.userAccelYBias,
                    userAccelZ: motion.userAcceleration.z - self.userAccelZBias,
                    gravityAccelX: motion.gravity.x - self.gravityAccelXBias,
                    gravityAccelY: motion.gravity.y - self.gravityAccelYBias,
                    gravityAccelZ: motion.gravity.z - self.gravityAccelZBias
                )
                
                let rawNewData = AirPodsMotionData(
                    timestamp: Date(),
                    elapsedTime: self.getElapsedTime(),
                    pitch: motion.attitude.pitch,
                    yaw: motion.attitude.yaw,
                    roll: motion.attitude.roll,
                    rotationRateX: motion.rotationRate.x,
                    rotationRateY: motion.rotationRate.y,
                    rotationRateZ: motion.rotationRate.z,
                    userAccelX: motion.userAcceleration.x,
                    userAccelY: motion.userAcceleration.y,
                    userAccelZ: motion.userAcceleration.z,
                    gravityAccelX: motion.gravity.x,
                    gravityAccelY: motion.gravity.y,
                    gravityAccelZ: motion.gravity.z
                )
                
                
                DispatchQueue.main.async {
                    self.lastSensorData = newData
                    self.latestUncalibratedData = rawNewData
                    self.sensorData.append(newData)
                    
                    if (self.isCollectingTrainData) {
                        self.tempData.append(newData)
                    }
                    
                    self.prediction = self.predictionService.predictViewingDirection(data: newData)
                    self.modelPrediction = self.predictionService.airpodsPrediction(motionData: motion)
                    
                    switch motion.sensorLocation {
                    case .headphoneLeft:
                        self.sensorlocation = "Links"
                    case .headphoneRight:
                        self.sensorlocation = "Rechts"
                    case .default:
                        self.sensorlocation = "Default"
                    @unknown default:
                        self.sensorlocation = "Default"
                    }
                    
                }
                
            }
        }
        
    }
    
    func calibrate(data: AirPodsMotionData) {
        self.pitchBias = data.pitch
        self.yawBias = data.yaw
        self.rollBias = data.roll
        
        self.rotationRateXBias = data.rotationRateX
        self.rotationRateYBias = data.rotationRateY
        self.rotationRateZBias = data.rotationRateZ
        
        self.userAccelXBias = data.userAccelX
        self.userAccelYBias = data.userAccelY
        self.userAccelZBias = data.userAccelZ
        
        self.gravityAccelXBias = data.gravityAccelX
        self.gravityAccelYBias = data.gravityAccelY
        self.gravityAccelZBias = data.gravityAccelZ
      
    }
    
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
