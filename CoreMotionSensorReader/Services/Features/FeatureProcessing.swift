//
//  FeatureProcessing.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.03.25.
//

import Foundation
import Accelerate



struct ScalerParameters {
    let mean: [Double]
    let std: [Double]
    
    static let defaultScaler = ScalerParameters(
        mean: [1.8971770950852287, -0.3905246968123367, 0.0834210884892834, 1.051146970619584],
        std: [0.8398078775682413, 0.446277655818336, 0.6828262178820128, 0.2436906230362451]
    )
}

struct SensorFeatures {
    // Acceleration features
    let accelerationX_max: Double
    let accelerationX_min: Double
    let accelerationX_mean: Double
    let accelerationX_std: Double
    let accelerationX_median: Double
    let accelerationX_rms: Double
    
    let accelerationY_max: Double
    let accelerationY_min: Double
    let accelerationY_mean: Double
    let accelerationY_std: Double
    let accelerationY_median: Double
    let accelerationY_rms: Double
    
    let accelerationZ_max: Double
    let accelerationZ_min: Double
    let accelerationZ_mean: Double
    let accelerationZ_std: Double
    let accelerationZ_median: Double
    let accelerationZ_rms: Double
    
    // Orientation features
    let pitch_max: Double
    let pitch_min: Double
    let pitch_mean: Double
    let pitch_std: Double
    
    let roll_max: Double
    let roll_min: Double
    let roll_mean: Double
    let roll_std: Double
    
    let yaw_max: Double
    let yaw_min: Double
    let yaw_mean: Double
    let yaw_std: Double
    
    // Rotation rate features
    let rotationRateX_max: Double
    let rotationRateX_min: Double
    let rotationRateX_mean: Double
    let rotationRateX_std: Double
    
    let rotationRateY_max: Double
    let rotationRateY_min: Double
    let rotationRateY_mean: Double
    let rotationRateY_std: Double
    
    let rotationRateZ_max: Double
    let rotationRateZ_min: Double
    let rotationRateZ_mean: Double
    let rotationRateZ_std: Double
    
    // User acceleration features
    let userAccelX_max: Double
    let userAccelX_min: Double
    let userAccelX_mean: Double
    let userAccelX_std: Double
    
    let userAccelY_max: Double
    let userAccelY_min: Double
    let userAccelY_mean: Double
    let userAccelY_std: Double
    
    let userAccelZ_max: Double
    let userAccelZ_min: Double
    let userAccelZ_mean: Double
    let userAccelZ_std: Double
    
    // Gravity acceleration features
    let gravityAccelX_max: Double
    let gravityAccelX_min: Double
    let gravityAccelX_mean: Double
    let gravityAccelX_std: Double
    
    let gravityAccelY_max: Double
    let gravityAccelY_min: Double
    let gravityAccelY_mean: Double
    let gravityAccelY_std: Double
    
    let gravityAccelZ_max: Double
    let gravityAccelZ_min: Double
    let gravityAccelZ_mean: Double
    let gravityAccelZ_std: Double
    
}

class FeatureProcessing {
    
    // Sample count for a 65Hz window over 1 second
    let sampleCount = 65
    
    func computeFeatures(from data: [SensorData]) -> SensorFeatures {
        // Extract raw data
        var accelerationX: [Double] = []
        var accelerationY: [Double] = []
        var accelerationZ: [Double] = []
        
        var pitchValues: [Double] = []
        var yawValues: [Double] = []
        var rollValues: [Double] = []
        
        var rotationRateX: [Double] = []
        var rotationRateY: [Double] = []
        var rotationRateZ: [Double] = []
        
        var userAccelX: [Double] = []
        var userAccelY: [Double] = []
        var userAccelZ: [Double] = []
        
        var gravityAccelX: [Double] = []
        var gravityAccelY: [Double] = []
        var gravityAccelZ: [Double] = []

        // Extract data points from sensor data
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
                
                rotationRateX.append(motion.rotationRateX)
                rotationRateY.append(motion.rotationRateY)
                rotationRateZ.append(motion.rotationRateZ)
                
                userAccelX.append(motion.userAccelX)
                userAccelY.append(motion.userAccelY)
                userAccelZ.append(motion.userAccelZ)
                
                gravityAccelX.append(motion.gravityAccelX)
                gravityAccelY.append(motion.gravityAccelY)
                gravityAccelZ.append(motion.gravityAccelZ)
            }
        }
        
        // Calculate statistical features for acceleration
        let accelXStats = calculateStatistics(from: accelerationX)
        let accelYStats = calculateStatistics(from: accelerationY)
        let accelZStats = calculateStatistics(from: accelerationZ)
        
        // Calculate statistical features for orientation
        let pitchStats = calculateBasicStatistics(from: pitchValues)
        let yawStats = calculateBasicStatistics(from: yawValues)
        let rollStats = calculateBasicStatistics(from: rollValues)
        
        // Calculate statistical features for rotation rate
        let rotationRateXStats = calculateBasicStatistics(from: rotationRateX)
        let rotationRateYStats = calculateBasicStatistics(from: rotationRateY)
        let rotationRateZStats = calculateBasicStatistics(from: rotationRateZ)
        
        // Calculate statistical features for user acceleration
        let userAccelXStats = calculateBasicStatistics(from: userAccelX)
        let userAccelYStats = calculateBasicStatistics(from: userAccelY)
        let userAccelZStats = calculateBasicStatistics(from: userAccelZ)
        
        // Calculate statistical features for gravity acceleration
        let gravityAccelXStats = calculateBasicStatistics(from: gravityAccelX)
        let gravityAccelYStats = calculateBasicStatistics(from: gravityAccelY)
        let gravityAccelZStats = calculateBasicStatistics(from: gravityAccelZ)
        


        return SensorFeatures(
            // Acceleration features
            accelerationX_max: accelXStats.max,
            accelerationX_min: accelXStats.min,
            accelerationX_mean: accelXStats.mean,
            accelerationX_std: accelXStats.std,
            accelerationX_median: accelXStats.median,
            accelerationX_rms: accelXStats.rms,
            
            accelerationY_max: accelYStats.max,
            accelerationY_min: accelYStats.min,
            accelerationY_mean: accelYStats.mean,
            accelerationY_std: accelYStats.std,
            accelerationY_median: accelYStats.median,
            accelerationY_rms: accelYStats.rms,
            
            accelerationZ_max: accelZStats.max,
            accelerationZ_min: accelZStats.min,
            accelerationZ_mean: accelZStats.mean,
            accelerationZ_std: accelZStats.std,
            accelerationZ_median: accelZStats.median,
            accelerationZ_rms: accelZStats.rms,
            
            // Orientation features
            pitch_max: pitchStats.max,
            pitch_min: pitchStats.min,
            pitch_mean: pitchStats.mean,
            pitch_std: pitchStats.std,
            
            roll_max: rollStats.max,
            roll_min: rollStats.min,
            roll_mean: rollStats.mean,
            roll_std: rollStats.std,
            
            yaw_max: yawStats.max,
            yaw_min: yawStats.min,
            yaw_mean: yawStats.mean,
            yaw_std: yawStats.std,
            
            // Rotation rate features
            rotationRateX_max: rotationRateXStats.max,
            rotationRateX_min: rotationRateXStats.min,
            rotationRateX_mean: rotationRateXStats.mean,
            rotationRateX_std: rotationRateXStats.std,
            
            rotationRateY_max: rotationRateYStats.max,
            rotationRateY_min: rotationRateYStats.min,
            rotationRateY_mean: rotationRateYStats.mean,
            rotationRateY_std: rotationRateYStats.std,
            
            rotationRateZ_max: rotationRateZStats.max,
            rotationRateZ_min: rotationRateZStats.min,
            rotationRateZ_mean: rotationRateZStats.mean,
            rotationRateZ_std: rotationRateZStats.std,
            
            // User acceleration features
            userAccelX_max: userAccelXStats.max,
            userAccelX_min: userAccelXStats.min,
            userAccelX_mean: userAccelXStats.mean,
            userAccelX_std: userAccelXStats.std,
            
            userAccelY_max: userAccelYStats.max,
            userAccelY_min: userAccelYStats.min,
            userAccelY_mean: userAccelYStats.mean,
            userAccelY_std: userAccelYStats.std,
            
            userAccelZ_max: userAccelZStats.max,
            userAccelZ_min: userAccelZStats.min,
            userAccelZ_mean: userAccelZStats.mean,
            userAccelZ_std: userAccelZStats.std,
            
            // Gravity acceleration features
            gravityAccelX_max: gravityAccelXStats.max,
            gravityAccelX_min: gravityAccelXStats.min,
            gravityAccelX_mean: gravityAccelXStats.mean,
            gravityAccelX_std: gravityAccelXStats.std,
            
            gravityAccelY_max: gravityAccelYStats.max,
            gravityAccelY_min: gravityAccelYStats.min,
            gravityAccelY_mean: gravityAccelYStats.mean,
            gravityAccelY_std: gravityAccelYStats.std,
            
            gravityAccelZ_max: gravityAccelZStats.max,
            gravityAccelZ_min: gravityAccelZStats.min,
            gravityAccelZ_mean: gravityAccelZStats.mean,
            gravityAccelZ_std: gravityAccelZStats.std
            
        
        )
    }
    
    // Struct to hold all statistical values for a signal
    private struct SignalStats {
        let mean: Double
        let std: Double
        let min: Double
        let max: Double
        let median: Double
        let rms: Double
    }
    
    // Struct for basic statistics (subset of full statistics)
    private struct BasicStats {
        let mean: Double
        let std: Double
        let min: Double
        let max: Double
    }
    
    // Calculate comprehensive statistics for a signal using Accelerate
    private func calculateStatistics(from signal: [Double]) -> SignalStats {
        guard !signal.isEmpty else {
            return SignalStats(mean: 0, std: 0, min: 0, max: 0, median: 0, rms: 0)
        }
        
        let count = vDSP_Length(signal.count)
        _ = Double(count)
        
        // Mean
        var mean: Double = 0
        vDSP_meanvD(signal, 1, &mean, count)
        
        // Min and Max
        var min: Double = 0
        var max: Double = 0
        vDSP_minvD(signal, 1, &min, count)
        vDSP_maxvD(signal, 1, &max, count)
        
        // Standard Deviation
        var variance: Double = 0
        var std: Double = 0
        
        // Calculate variance: mean of (x - mean)^2
        let meanArray = Array(repeating: mean, count: Int(count))
        var differences = [Double](repeating: 0, count: Int(count))
        vDSP_vsubD(meanArray, 1, signal, 1, &differences, 1, count)
        
        var squaredDifferences = [Double](repeating: 0, count: Int(count))
        vDSP_vsqD(differences, 1, &squaredDifferences, 1, count)
        
        vDSP_meanvD(squaredDifferences, 1, &variance, count)
        std = sqrt(variance)
        
        // Median (sort the array first)
        let sortedSignal = signal.sorted()
        let median = count % 2 == 0 ?
            (sortedSignal[Int(count/2)] + sortedSignal[Int(count/2 - 1)]) / 2 :
            sortedSignal[Int(count/2)]
        
        // RMS (Root Mean Square)
        var squaredSum: Double = 0
        var squares = [Double](repeating: 0, count: Int(count))
        vDSP_vsqD(signal, 1, &squares, 1, count)
        vDSP_meanvD(squares, 1, &squaredSum, count)
        let rms = sqrt(squaredSum)
        
        return SignalStats(
            mean: mean,
            std: std,
            min: min,
            max: max,
            median: median,
            rms: rms
        )
    }
    
    // Calculate basic statistics for signals where full statistics aren't needed
    private func calculateBasicStatistics(from signal: [Double]) -> BasicStats {
        guard !signal.isEmpty else {
            return BasicStats(mean: 0, std: 0, min: 0, max: 0)
        }
        
        let count = vDSP_Length(signal.count)
        let doubleCount = Double(count)
        
        // Mean
        var mean: Double = 0
        vDSP_meanvD(signal, 1, &mean, count)
        
        // Min and Max
        var min: Double = 0
        var max: Double = 0
        vDSP_minvD(signal, 1, &min, count)
        vDSP_maxvD(signal, 1, &max, count)
        
        // Standard Deviation
        var variance: Double = 0
        var std: Double = 0
        
        // Calculate variance: mean of (x - mean)^2
        let meanArray = Array(repeating: mean, count: Int(count))
        var differences = [Double](repeating: 0, count: Int(count))
        vDSP_vsubD(meanArray, 1, signal, 1, &differences, 1, count)
        
        var squaredDifferences = [Double](repeating: 0, count: Int(count))
        vDSP_vsqD(differences, 1, &squaredDifferences, 1, count)
        
        vDSP_meanvD(squaredDifferences, 1, &variance, count)
        std = sqrt(variance)
        
        return BasicStats(mean: mean, std: std, min: min, max: max)
    }
    
    
    // Calculate the magnitude of 3D vector (sqrt(x^2 + y^2 + z^2))
    private func calculateMagnitude(x: [Double], y: [Double], z: [Double]) -> Double {
        guard !x.isEmpty && !y.isEmpty && !z.isEmpty else { return 0 }
        
        // Find shortest length
        let minLength = vDSP_Length(min(min(x.count, y.count), z.count))
        
        // Ensure all arrays have same length
        let xTrimmed = Array(x.prefix(Int(minLength)))
        let yTrimmed = Array(y.prefix(Int(minLength)))
        let zTrimmed = Array(z.prefix(Int(minLength)))
        
        // Square each component
        var xSquared = [Double](repeating: 0, count: Int(minLength))
        var ySquared = [Double](repeating: 0, count: Int(minLength))
        var zSquared = [Double](repeating: 0, count: Int(minLength))
        vDSP_vsqD(xTrimmed, 1, &xSquared, 1, minLength)
        vDSP_vsqD(yTrimmed, 1, &ySquared, 1, minLength)
        vDSP_vsqD(zTrimmed, 1, &zSquared, 1, minLength)
        
        // Sum the components
        var sumOfSquares = [Double](repeating: 0, count: Int(minLength))
        vDSP_vaddD(xSquared, 1, ySquared, 1, &sumOfSquares, 1, minLength)
        vDSP_vaddD(sumOfSquares, 1, zSquared, 1, &sumOfSquares, 1, minLength)
        
        // Calculate square root
        var magnitude = [Double](repeating: 0, count: Int(minLength))
        vvsqrt(&magnitude, sumOfSquares, [Int32(minLength)])
        
        // Calculate mean magnitude
        var meanMagnitude: Double = 0
        vDSP_meanvD(magnitude, 1, &meanMagnitude, minLength)
        
        return meanMagnitude
    }
    
    // Calculate jerk (rate of change of acceleration)
    private func calculateJerkMagnitude(x: [Double], y: [Double], z: [Double]) -> Double {
        guard x.count > 1 && y.count > 1 && z.count > 1 else { return 0 }
        
        // Find shortest length
        let minLength = vDSP_Length(min(min(x.count, y.count), z.count))
        
        // Ensure all arrays have same length
        let xTrimmed = Array(x.prefix(Int(minLength)))
        let yTrimmed = Array(y.prefix(Int(minLength)))
        let zTrimmed = Array(z.prefix(Int(minLength)))
        
        // Calculate differences (derivatives)
        var xDiff = [Double](repeating: 0, count: Int(minLength - 1))
        var yDiff = [Double](repeating: 0, count: Int(minLength - 1))
        var zDiff = [Double](repeating: 0, count: Int(minLength - 1))
        
        for i in 0..<(Int(minLength - 1)) {
            xDiff[i] = xTrimmed[i+1] - xTrimmed[i]
            yDiff[i] = yTrimmed[i+1] - yTrimmed[i]
            zDiff[i] = zTrimmed[i+1] - zTrimmed[i]
        }
        
        // Calculate magnitude of jerk
        return calculateMagnitude(x: xDiff, y: yDiff, z: zDiff)
    }
    
    // Calculate the required features for the model
    func calculateModelFeatures(from features: SensorFeatures) -> [Double] {
        // Calculate gyro_squared (sum of squares of rotation rates)
        let gyroSquared = features.rotationRateX_mean * features.rotationRateX_mean +
                         features.rotationRateY_mean * features.rotationRateY_mean +
                         features.rotationRateZ_mean * features.rotationRateZ_mean
        
        // Use mean pitch as pitch_filtered
        let pitchFiltered = features.pitch_mean
        
        // Use mean accelerationX as accelerationX_filtered
        let accelerationXFiltered = features.accelerationX_mean
        
        // Calculate acc_squared (sum of squares of accelerations)
        let accSquared = features.accelerationX_mean * features.accelerationX_mean +
                        features.accelerationY_mean * features.accelerationY_mean +
                        features.accelerationZ_mean * features.accelerationZ_mean
        
        return [gyroSquared, pitchFiltered, accelerationXFiltered, accSquared]
    }
    
    func standardizeFeatures(_ features: SensorFeatures, using scaler: ScalerParams = ScalerParams.defaultScaler) -> [Double] {
        // Calculate the required features for the model
        let modelFeatures = calculateModelFeatures(from: features)
        
        guard modelFeatures.count == scaler.mean.count, modelFeatures.count == scaler.std.count else {
            print("Fehler: Dimensionen von Features und Scaler-Parametern stimmen nicht überein.")
            return modelFeatures
        }
        
        return zip(modelFeatures, zip(scaler.mean, scaler.std)).map { (value, params) in
            let (mean, std) = params
            return (value - mean) / std
        }
    }
    
    // Method to get all features as an array (useful for ML models that need all features)
    func getAllFeaturesAsArray(_ features: SensorFeatures) -> [Double] {
        return [
            // Acceleration features
            features.accelerationX_max, features.accelerationX_min, features.accelerationX_mean,
            features.accelerationX_std, features.accelerationX_median, features.accelerationX_rms,
            
            features.accelerationY_max, features.accelerationY_min, features.accelerationY_mean,
            features.accelerationY_std, features.accelerationY_median, features.accelerationY_rms,
            
            features.accelerationZ_max, features.accelerationZ_min, features.accelerationZ_mean,
            features.accelerationZ_std, features.accelerationZ_median, features.accelerationZ_rms,
            
            // Orientation features
            features.pitch_max, features.pitch_min, features.pitch_mean, features.pitch_std,
            features.roll_max, features.roll_min, features.roll_mean, features.roll_std,
            features.yaw_max, features.yaw_min, features.yaw_mean, features.yaw_std,
            
            // Rotation rate features
            features.rotationRateX_max, features.rotationRateX_min, features.rotationRateX_mean,
            features.rotationRateX_std,
            
            features.rotationRateY_max, features.rotationRateY_min, features.rotationRateY_mean,
            features.rotationRateY_std,
            
            features.rotationRateZ_max, features.rotationRateZ_min, features.rotationRateZ_mean,
            features.rotationRateZ_std,
            
            // User acceleration features
            features.userAccelX_max, features.userAccelX_min, features.userAccelX_mean,
            features.userAccelX_std,
            
            features.userAccelY_max, features.userAccelY_min, features.userAccelY_mean,
            features.userAccelY_std,
            
            features.userAccelZ_max, features.userAccelZ_min, features.userAccelZ_mean,
            features.userAccelZ_std,
            
            // Gravity acceleration features
            features.gravityAccelX_max, features.gravityAccelX_min, features.gravityAccelX_mean,
            features.gravityAccelX_std,
            
            features.gravityAccelY_max, features.gravityAccelY_min, features.gravityAccelY_mean,
            features.gravityAccelY_std,
            
            features.gravityAccelZ_max, features.gravityAccelZ_min, features.gravityAccelZ_mean,
            features.gravityAccelZ_std
        ]
    }
    
    private func calculateSumOfSquares(_ signals: [Double]...) -> Double {
          return signals.reduce(0) { sum, signal in
              var squaredSum: Double = 0
              vDSP_sveD(signal.map { $0 * $0 }, 1, &squaredSum, vDSP_Length(signal.count))
              return sum + squaredSum
          }
      }
}

    
