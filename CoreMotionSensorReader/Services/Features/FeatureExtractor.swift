//
//  FeatureExtractor.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation
import Accelerate


//reduced: mean: [0.21455301516969322, 0.06466442414965638, 0.1781116257348689, 0.02481909410710424, 1.6645067012282806],
//reduced std: [0.2501521901060052, 0.22570118169428124, 0.1775076154913816, 0.10186794110281397, 1.5693998176383293]

/* alt:
 mean: [-0.5356399882163667, -0.8957487554202017, 0.8047723287895919, 0.07791302983790317],
 std: [0.4939388256052858, 1.5746934389624043, 0.7994948541061939, 0.22287172605741165]
 */


struct ScalerParams {
    let mean: [Double]
    let std: [Double]
    
    static let defaultScaler = ScalerParams(
        mean: [0.21455301516969322, 0.06466442414965638, 0.1781116257348689, 0.02481909410710424, 1.6645067012282806],
        std: [0.2501521901060052, 0.22570118169428124, 0.1775076154913816, 0.10186794110281397, 1.5693998176383293]
    )
}

struct SensorFeaturesThreeModel {
    let pitch_filtered_min: Double
    let  yaw_filtered_min: Double
    let roll_filtered_max: Double
    let userAccelX_filtered_mean: Double
    
}

struct SensorFeatures {
    let userAccelY_std: Double
    let userAccelX_mean: Double
    let userAccelX_std: Double
    let userAccelZ_mean: Double
    let rotation_magnitude: Double
}

class FeatureExtractor {
    
    // Function to scale values using mean and std
       func scale(value: Double, index: Int) -> Double {
           let mean = ScalerParams.defaultScaler.mean[index]
           let std = ScalerParams.defaultScaler.std[index]
           return (value - mean) / std
       }
       
       func computeFeatures(from data: [SensorData]) -> SensorFeatures {
           var userAccelXValues: [Double] = []
           var userAccelYValues: [Double] = []
           var userAccelZValues: [Double] = []
           var rotationRateXValues: [Double] = []
           var rotationRateYValues: [Double] = []
           var rotationRateZValues: [Double] = []
           
           for entry in data {
               if let motion = entry.deviceMotionData {
                   userAccelXValues.append(motion.userAccelX)
                   userAccelYValues.append(motion.userAccelY)
                   userAccelZValues.append(motion.userAccelZ)
                   rotationRateXValues.append(motion.rotationRateX)
                   rotationRateYValues.append(motion.rotationRateY)
                   rotationRateZValues.append(motion.rotationRateZ)
               }
           }
           
           // Berechnungen für Mittelwerte und Standardabweichungen
           let userAccelXMean = userAccelXValues.reduce(0, +) / Double(userAccelXValues.count)
           let userAccelXStd = standardDeviation(of: userAccelXValues)
           let userAccelYStd = standardDeviation(of: userAccelYValues)
           let userAccelZMean = userAccelZValues.reduce(0, +) / Double(userAccelZValues.count)
           
           // Berechnung der euklidischen Magnitude der Rotation
           let rotationMagnitude = eucledianMagnitude(x: rotationRateXValues, y: rotationRateYValues, z: rotationRateZValues)
           
           // Skalieren der berechneten Features
           let scaledUserAccelXMean = scale(value: userAccelXMean, index: 1)
           let scaledUserAccelXStd = scale(value: userAccelXStd, index: 2)
           let scaledUserAccelYStd = scale(value: userAccelYStd, index: 0)
           let scaledUserAccelZMean = scale(value: userAccelZMean, index: 3)
           let scaledRotationMagnitude = scale(value: rotationMagnitude, index: 4)
           
           // Features in ein Objekt verpacken
           return SensorFeatures(
               userAccelY_std: scaledUserAccelYStd,
               userAccelX_mean: scaledUserAccelXMean,
               userAccelX_std: scaledUserAccelXStd,
               userAccelZ_mean: scaledUserAccelZMean,
               rotation_magnitude: scaledRotationMagnitude
           )
       }
       
       // Funktion zur Berechnung der Standardabweichung
       func standardDeviation(of values: [Double]) -> Double {
           let mean = values.reduce(0, +) / Double(values.count)
           let sumOfSquaredDifferences = values.reduce(0) { $0 + pow($1 - mean, 2) }
           return sqrt(sumOfSquaredDifferences / Double(values.count))
       }
       
       // Berechnung der euklidischen Magnitude für Rotationsraten
       func eucledianMagnitude(x: [Double], y: [Double], z: [Double]) -> Double {
           let magnitudes = zip(zip(x, y), z).map { (xy, z) in
               return sqrt(pow(xy.0, 2) + pow(xy.1, 2) + pow(z, 2))
           }
           return magnitudes.reduce(0, +) / Double(magnitudes.count)
       }
}


