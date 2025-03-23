//
//  ModelService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 11.03.25.
//

import Foundation
import CoreML

class ModelService {
    let modelReduced: ReducedTestModel
    
    init?() {
        do {
            self.modelReduced = try ReducedTestModel(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }


    func classifyReducedFeatures(features: SensorFeatures) -> String? {
        do {
            let input = ReducedTestModelInput(
                userAccelY_std: features.userAccelX_std, userAccelX_mean: features.userAccelX_mean, userAccelX_std: features.userAccelX_std, userAccelZ_mean: features.userAccelZ_mean, rotation_magnitude: features.rotation_magnitude
            )
            
            let prediction = try modelReduced.prediction(input: input)
            return prediction.label
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
}
