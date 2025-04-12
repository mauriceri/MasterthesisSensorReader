//
//  ModelService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 11.03.25.
//

import Foundation
import CoreML

class ModelService {
    let modelReduced: RandomForestReducedLabel
    let modelFull: RandomForestFullLabel
    
    init?() {
        do {
            self.modelReduced = try RandomForestReducedLabel(configuration: MLModelConfiguration())
            self.modelFull = try RandomForestFullLabel(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }

    func classifyReducedFeatures(features: SensorFeatures) -> String? {
        do {
            let input = RandomForestReducedLabelInput(
                rotationRateZ_std: features.rotationRateZ_std,
                rotationRateZ_max: features.rotationRateZ_max,
                accelerationY_max: features.accelerationY_max,
                rotationRateZ_min: features.rotationRateZ_min,
                gravityAccelY_max: features.gravityAccelY_max,
                userAccelY_std: features.userAccelY_std,
                roll_min: features.roll_min,
                pitch_min: features.pitch_min,
                gravityAccelX_min: features.gravityAccelX_min,
                gravityaccel_squared_var_coeff: features.gravityAccelSquaredVarCoeff
            )
            
            let prediction = try modelReduced.prediction(input: input)
            let predictedLabel = LabelMapper.getLabel(for: Int(prediction.label))
        
            
            return predictedLabel
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
    
    func classifyFullFeatures(features: SensorFeaturesAllLabel) -> String? {
        do {
            let input = RandomForestFullLabelInput(
                pitch_min: features.pitch_min,
                gravityAccelZ_max: features.gravityAccelZ_max,
                gravityAccelY_max: features.gravityAccelY_max,
                rotationRateZ_std: features.rotationRateZ_std,
                gravityAccelZ_min: features.gravityAccelZ_min,
                rotationRateZ_max: features.rotationRateZ_max,
                accelerationY_max: features.accelerationY_max,
                roll_min: features.roll_min,
                roll_std: features.roll_std,
                gravityAccelX_min: features.gravityAccelX_min
                )
            
            let prediction = try modelFull.prediction(input: input)
            let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(prediction.classLabel))
            
            return predictedLabel
        } catch{
            print("Prediction error: \(error)")
            return nil
        }
        
    }
}
