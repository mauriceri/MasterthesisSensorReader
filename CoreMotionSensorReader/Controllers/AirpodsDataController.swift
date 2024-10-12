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
    
    
    
    var prediction: String = "-"
    var modelPrediction: String = "-"
    var sensorlocation: String = "-"
    
    private var decimalPlaces = 5
    
    
    override init() {
        super.init()
        motionManager.delegate = self
        startHeadphoneData()
    }
    
    func exportToCsv() -> Void {
        csvWriter.exportCSV(from: sensorData, to: "Airpods.csv")
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
    
    func setDecimalPlaces(places: Int) -> Void {
        self.decimalPlaces = places
    }
    
    func getElapsedTime() -> TimeInterval {
        guard let first = sensorData.first, let last = sensorData.last else {
            return 0
        }
        return last.timestamp.timeIntervalSince(first.timestamp)
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
                    pitch: motion.attitude.pitch.rounded(toPlaces: self.decimalPlaces),
                    yaw: motion.attitude.yaw.rounded(toPlaces: self.decimalPlaces),
                    roll: motion.attitude.roll.rounded(toPlaces: self.decimalPlaces),
                    rotationRateX: motion.rotationRate.x.rounded(toPlaces: self.decimalPlaces),
                    rotationRateY: motion.rotationRate.y.rounded(toPlaces: self.decimalPlaces),
                    rotationRateZ: motion.rotationRate.z.rounded(toPlaces: self.decimalPlaces),
                    userAccelX: motion.userAcceleration.x.rounded(toPlaces: self.decimalPlaces),
                    userAccelY: motion.userAcceleration.y.rounded(toPlaces: self.decimalPlaces),
                    userAccelZ: motion.userAcceleration.z.rounded(toPlaces: self.decimalPlaces),
                    gravityAccelX: motion.gravity.x.rounded(toPlaces: self.decimalPlaces),
                    gravityAccelY: motion.gravity.y.rounded(toPlaces: self.decimalPlaces),
                    gravityAccelZ: motion.gravity.z.rounded(toPlaces: self.decimalPlaces)
                )
                
                DispatchQueue.main.async {
                    self.lastSensorData = newData
                    self.sensorData.append(newData)
                    
                    self.prediction = self.predictionService.predictViewingDirection(data: motion)
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
    
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
