//
//  ButterworthLowPassFilter.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 25.04.25.
//


import Foundation

//let filter = ButterworthLowPassFilter(cutoffFrequency: 500.0, sampleRate: 44100.0)
//let filteredSample = filter.process(sample: someInputSample)

class ButterworthLowPassFilter {
    private var a0: Float = 0
    private var a1: Float = 0
    private var a2: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0

    private var x1: Float = 0, x2: Float = 0
    private var y1: Float = 0, y2: Float = 0

    init(cutoffFrequency: Float, sampleRate: Float) {
        setupCoefficients(cutoff: cutoffFrequency, sampleRate: sampleRate)
    }

    private func setupCoefficients(cutoff: Float, sampleRate: Float) {
        let omega = 2.0 * Float.pi * cutoff / sampleRate
        let sinOmega = sin(omega)
        let cosOmega = cos(omega)
        let Q: Float = 1.0 / sqrt(2.0) // Butterworth Q

        let alpha = sinOmega / (2.0 * Q)

        let b0 = (1 - cosOmega) / 2
        let b1 = 1 - cosOmega
        let b2 = (1 - cosOmega) / 2
        let a0 = 1 + alpha
        let a1 = -2 * cosOmega
        let a2 = 1 - alpha

        self.a0 = b0 / a0
        self.a1 = b1 / a0
        self.a2 = b2 / a0
        self.b1 = a1 / a0
        self.b2 = a2 / a0
    }

    func process(sample: Float) -> Float {
        let result = a0 * sample + a1 * x1 + a2 * x2
                     - b1 * y1 - b2 * y2

        // Shift samples for next time
        x2 = x1
        x1 = sample
        y2 = y1
        y1 = result

        return result
    }
}
