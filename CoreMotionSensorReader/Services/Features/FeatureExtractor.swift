//
//  FeatureExtractor.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation
import Accelerate

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


struct ScaledFeature {
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
    
    func scaleFeatures(features: SensorFeaturesAllLabel) -> ScaledFeature {
        let means = [-0.59493994, -0.27698391,  0.48371406,  1.11787349, -0.60216707,  1.7629554,
                     0.72492358, -0.20636859,  0.35970556, -0.1498855]
        
        let stdDevs = [0.51220974, 0.40951295, 0.37199073, 1.33631733, 0.36647821, 2.10464533,
                       0.61559696, 1.10809129, 0.38818016, 0.60612554]

        let scaledPitchMin = (features.pitch_min - means[0]) / stdDevs[0]
        let scaledGravityAccelZMax = (features.gravityAccelZ_max - means[1]) / stdDevs[1]
        let scaledGravityAccelYMax = (features.gravityAccelY_max - means[2]) / stdDevs[2]
        let scaledRotationRateZStd = (features.rotationRateZ_std - means[3]) / stdDevs[3]
        let scaledGravityAccelZMin = (features.gravityAccelZ_min - means[4]) / stdDevs[4]
        let scaledRotationRateZMax = (features.rotationRateZ_max - means[5]) / stdDevs[5]
        let scaledAccelerationYMax = (features.accelerationY_max - means[6]) / stdDevs[6]
        let scaledRollMin = (features.roll_min - means[7]) / stdDevs[7]
        let scaledRollStd = (features.roll_std - means[8]) / stdDevs[8]
        let scaledGravityAccelXMin = (features.gravityAccelX_min - means[9]) / stdDevs[9]
        
        return ScaledFeature(
            pitch_min: scaledPitchMin,
            gravityAccelZ_max: scaledGravityAccelZMax,
            gravityAccelY_max: scaledGravityAccelYMax,
            rotationRateZ_std: scaledRotationRateZStd,
            gravityAccelZ_min: scaledGravityAccelZMin,
            rotationRateZ_max: scaledRotationRateZMax,
            accelerationY_max: scaledAccelerationYMax,
            roll_min: scaledRollMin,
            roll_std: scaledRollStd,
            gravityAccelX_min: scaledGravityAccelXMin
        )
    }
}

