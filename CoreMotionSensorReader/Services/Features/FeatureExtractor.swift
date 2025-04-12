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
        mean: [ 1.49584231,  2.32193533,  0.94175419, -2.26208662,  0.64448792,  0.28287349,
                -0.0790468,  -0.80686126, -0.06297699,  0.01790369],
        std: [1.4702313 , 2.32698841, 0.61716279 ,2.16311315, 0.32188388 ,0.27951477
              ,1.23603774, 0.47592983 ,0.63687188 ,0.02990101]
    )
}

struct SensorFeatures {
    let rotationRateZ_std: Double
    let rotationRateZ_max: Double
    let accelerationY_max: Double
    let rotationRateZ_min: Double
    let gravityAccelY_max: Double
    let userAccelY_std: Double
    let roll_min: Double
    let pitch_min: Double
    let gravityAccelX_min: Double
    let gravityAccelSquaredVarCoeff: Double
}

struct SensorFeaturesAllLabel {
    var pitch_min: Double
    var gravityAccelZ_max: Double
    var gravityAccelY_max: Double
    var rotationRateZ_std: Double
    var gravityAccelZ_min: Double
    var rotationRateZ_max: Double
    var accelerationY_max: Double
    var roll_min: Double
    var roll_std: Double
    var gravityAccelX_min: Double
}

class FeatureExtractor {
    
    func scale(_ value: Double, index: Int) -> Double {
        let mean = ScalerParams.defaultScaler.mean[index]
        let std = ScalerParams.defaultScaler.std[index]
        return (value - mean) / std
    }
    
    func computeFeatures(from data: [SensorData]) -> SensorFeatures {
        var rotationRateZ: [Double] = []
        var userAccelX: [Double] = []
        var userAccelY: [Double] = []
        var userAccelZ: [Double] = []
        var gravityY: [Double] = []
        var gravityX: [Double] = []
        var roll: [Double] = []
        var pitch: [Double] = []
        
        for entry in data {
            if let motion = entry.deviceMotionData {
                rotationRateZ.append(motion.rotationRateZ)
                userAccelX.append(motion.userAccelX)
                userAccelY.append(motion.userAccelY)
                userAccelZ.append(motion.userAccelZ)
                gravityY.append(motion.gravityAccelY)
                gravityX.append(motion.gravityAccelX)
                roll.append(motion.roll)
                pitch.append(motion.pitch)
            }
        }
        
        let rZ_std = standardDeviation(of: rotationRateZ)
        let rZ_max = rotationRateZ.max() ?? 0.0
        let rZ_min = rotationRateZ.min() ?? 0.0
        let accelY_max = userAccelY.max() ?? 0.0
        let gravityY_max = gravityY.max() ?? 0.0
        let gravityX_min = gravityX.min() ?? 0.0
        let userAccelY_std = standardDeviation(of: userAccelY)
        let roll_min = roll.min() ?? 0.0
        let pitch_min = pitch.min() ?? 0.0
        
        
        let userAccelSquared: [Double] = zip(zip(userAccelX, userAccelY), userAccelZ).map { (xy, z) in
            let (x, y) = xy
            return x * x + y * y + z * z
        }
        
        let stdMag = standardDeviation(of: userAccelSquared)
        let meanMag = userAccelSquared.reduce(0, +) / Double(userAccelSquared.count)
        let varCoeff = stdMag / (meanMag + 1e-8)
        
        return SensorFeatures(
            rotationRateZ_std: rZ_std,
            rotationRateZ_max: rZ_max,
            accelerationY_max: accelY_max,
            rotationRateZ_min: rZ_min,
            gravityAccelY_max: gravityY_max,
            userAccelY_std: userAccelY_std,
            roll_min: roll_min,
            pitch_min: pitch_min,
            gravityAccelX_min: gravityX_min,
            gravityAccelSquaredVarCoeff: varCoeff
        )
    }
    
    func standardDeviation(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0.0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return sqrt(squaredDiffs.reduce(0, +) / Double(values.count))
    }
    
    
    func computeFeaturesAllLabel(from data: [SensorData]) -> SensorFeaturesAllLabel {
        var rotationRateZ: [Double] = []
        var userAccelY: [Double] = []
        var gravityAccelZ: [Double] = []
        var gravityAccelY: [Double] = []
        var gravityAccelX: [Double] = []
        var roll: [Double] = []
        var pitch: [Double] = []
        
        for entry in data {
            if let motion = entry.deviceMotionData {
                rotationRateZ.append(motion.rotationRateZ)
                userAccelY.append(motion.userAccelY)
                gravityAccelZ.append(motion.gravityAccelZ)
                gravityAccelY.append(motion.gravityAccelY)
                gravityAccelX.append(motion.gravityAccelX)
                roll.append(motion.roll)
                pitch.append(motion.pitch)
            }
        }
        
        return SensorFeaturesAllLabel(
            pitch_min: pitch.min() ?? 0.0,
            gravityAccelZ_max: gravityAccelZ.max() ?? 0.0,
            gravityAccelY_max: gravityAccelY.max() ?? 0.0,
            rotationRateZ_std: standardDeviation(of: rotationRateZ),
            gravityAccelZ_min: gravityAccelZ.min() ?? 0.0,
            rotationRateZ_max: rotationRateZ.max() ?? 0.0,
            accelerationY_max: userAccelY.max() ?? 0.0,
            roll_min: roll.min() ?? 0.0,
            roll_std: standardDeviation(of: roll),
            gravityAccelX_min: gravityAccelX.min() ?? 0.0
        )
    }
}

