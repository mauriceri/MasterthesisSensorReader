//
//  FeatureExtractor.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.02.25.
//

import Foundation
import Accelerate

class FeatureExtractor {

    func computeFeatures(from data: [SensorData]) -> SensorFeatures {
        var allValues: [[Double]] = []

        for entry in data {
            if let motion = entry.deviceMotionData {
                allValues.append([
                    motion.pitch, motion.yaw, motion.roll,
                    motion.rotationRateX, motion.rotationRateY, motion.rotationRateZ,
                    motion.userAccelX, motion.userAccelY, motion.userAccelZ,
                    motion.gravityAccelX, motion.gravityAccelY, motion.gravityAccelZ
                ])
            }
            if let accel = entry.accelerometerData {
                allValues.append([accel.accelerationX, accel.accelerationY, accel.accelerationZ])
            }
        }
        
        let flatValues = allValues.flatMap { $0 }
        
        // Min/Max berechnen
        let minValue = flatValues.min() ?? 0.0
        let maxValue = flatValues.max() ?? 0.0
        
        // Quadratwerte
        let squaredValues = flatValues.map { $0 * $0 }
        
        // FFT für Frequenzanalyse
        let fftMagnitudes = computeFFT(flatValues)
        
        return SensorFeatures(
            minValues: [minValue],
            maxValues: [maxValue],
            squaredValues: squaredValues,
            fftMagnitudes: fftMagnitudes
        )
    }
    
    func computeFFT(_ values: [Double]) -> [Double] {
        let count = values.count
        let log2n = vDSP_Length(log2(Double(count)))
        
        var real = values
        var imaginary = [Double](repeating: 0.0, count: count)
        
        return real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPDoubleSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                guard let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else {
                    return []
                }
                
                vDSP_fft_zipD(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_destroy_fftsetupD(fftSetup)
                
                var magnitudes = [Double](repeating: 0.0, count: count / 2)
                vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(count / 2))
                
                return magnitudes
            }
        }
    }

}
