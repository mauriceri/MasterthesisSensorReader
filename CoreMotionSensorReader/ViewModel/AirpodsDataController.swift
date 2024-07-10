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
    var sensorlocation: String = "-"
    
    
    override init() {
        super.init()
        motionManager.delegate = self
        startHeadphoneData()
    }
    
    func exportToCsv() -> Void {
        csvWriter.exportCSV(from: sensorData, to: "Test.csv")
    }
    
    func clearArray() -> Void {
        self.sensorData.removeAll()
    }
    
    
    func startHeadphoneData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
                
                guard let motion else {
                    print("keine motion")
                    return
                }
                
                let newData = AirPodsMotionData(pitch: motion.attitude.pitch,
                                                yaw: motion.attitude.yaw,
                                                roll: motion.attitude.roll,
                                                rotationRateX: motion.rotationRate.x,
                                                rotationRateY: motion.rotationRate.y,
                                                rotationRateZ: motion.rotationRate.z,
                                                userAccelX: motion.userAcceleration.x,
                                                userAccelY: motion.userAcceleration.y,
                                                userAccelZ: motion.userAcceleration.z,
                                                gravityAccelX: motion.gravity.x,
                                                gravityAccelY: motion.gravity.z,
                                                gravityAccelZ: motion.gravity.z)
                
                DispatchQueue.main.async {
                    self.lastSensorData = newData
                    self.sensorData.append(newData)
                    
                    self.prediction = self.predictionService.predictViewingDirection(data: motion)
                    
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
