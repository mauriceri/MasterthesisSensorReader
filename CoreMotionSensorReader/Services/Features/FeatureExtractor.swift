//
//  FeatureExtractor.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation
import Accelerate

struct ScalerParams {
    let mean: [Double]
    let std: [Double]
    
    static let defaultScaler = ScalerParams(
        mean: [1.8971770950852287, -0.3905246968123367, 0.0834210884892834, 1.051146970619584],
        std: [0.8398078775682413, 0.446277655818336, 0.6828262178820128, 0.2436906230362451]
    )
}

class FeatureExtractor {
    
    /*
    func computeFeatures(from data: [SensorData]) -> SensorFeatures {
        var accelerationX: [Double] = []
        var accelerationY: [Double] = []
        var accelerationZ: [Double] = []
        
        var pitchValues: [Double] = []
        var yawValues: [Double] = []
        var rollValues: [Double] = []

        for entry in data {
            if let accel = entry.accelerometerData {
                accelerationX.append(accel.accelerationX)
                accelerationY.append(accel.accelerationY)
                accelerationZ.append(accel.accelerationZ)
            }
            
            if let motion = entry.deviceMotionData {
                pitchValues.append(motion.pitch)
                yawValues.append(motion.yaw)
                rollValues.append(motion.roll)
            }
        }

        let accelerationX_max = accelerationX.max() ?? 0.0
        let accelerationX_min = accelerationX.min() ?? 0.0
        let accelerationY_max = accelerationY.max() ?? 0.0

        let accelerationY_mean = accelerationY.reduce(0, +) / Double(accelerationY.count)
        let accelerationY_variance = accelerationY.map { pow($0 - accelerationY_mean, 2) }.reduce(0, +) / Double(accelerationY.count)
        let accelerationY_std = sqrt(accelerationY_variance)

        let sumOfSquaresPitchYawRoll = pitchValues.map { $0 * $0 }.reduce(0, +) +
                                       yawValues.map { $0 * $0 }.reduce(0, +) +
                                       rollValues.map { $0 * $0 }.reduce(0, +)

        let sumOfSquaresAccel = accelerationX.map { $0 * $0 }.reduce(0, +) +
                                accelerationY.map { $0 * $0 }.reduce(0, +) +
                                accelerationZ.map { $0 * $0 }.reduce(0, +)

        let lastAccelerationX = accelerationX.last ?? 0.0
        let lastPitchValue = pitchValues.last ?? 0.0

        return SensorFeatures(
            accelerationX_max: accelerationX_max,
            accelerationX_min: accelerationX_min,
            accelerationY_max: accelerationY_max,
            accelerationY_std: accelerationY_std,
            sumOfSquaresPitchYawRoll: sumOfSquaresPitchYawRoll,
            sumOfSquaresAccel: sumOfSquaresAccel,
            accelerationX: lastAccelerationX,
            pitch: lastPitchValue
        )
    }
    
    func standardizeFeatures(_ features: SensorFeatures, using scaler: ScalerParams = ScalerParams.defaultScaler) -> [Double] {
        let featureArray = [
            features.sumOfSquaresPitchYawRoll,
            features.sumOfSquaresAccel,
            features.accelerationX,
            features.pitch
        ]
        
        guard featureArray.count == scaler.mean.count, featureArray.count == scaler.std.count else {
            print("Fehler: Dimensionen von Features und Scaler-Parametern stimmen nicht überein.")
            return featureArray
        }
        
        return zip(featureArray, zip(scaler.mean, scaler.std)).map { (value, params) in
            let (mean, std) = params
            return (value - mean) / std
        }
    }
     */
}

    
