//
//  LowPassFilter.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 24.03.25.
//

import Foundation

class LowPassFilter {
    var filteredValue: Double = 0.0
    let alpha: Double

    init(alpha: Double) {
        self.alpha = alpha
    }

    func filter(_ newValue: Double) -> Double {
        filteredValue = alpha * newValue + (1 - alpha) * filteredValue
        return filteredValue
    }
}
