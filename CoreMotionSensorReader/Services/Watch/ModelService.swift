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
    let modelFull: RF
    let decisionTree: DecisionTree
    let knn: Knn
    let svm: SVC
    
    init?() {
        do {
            self.modelReduced = try RandomForestReducedLabel(configuration: MLModelConfiguration())
            self.modelFull = try RF(configuration: MLModelConfiguration())
            self.decisionTree = try DecisionTree(configuration: MLModelConfiguration())
            self.knn = try Knn(configuration: MLModelConfiguration())
            self.svm = try SVC(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }
    
    func classifyRfReducedFeatures(features: SensorFeatures) -> String? {
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
            
            let classProbabilities = prediction.classProbability
            let totalProbability = classProbabilities.values.reduce(0, +)

            let normalizedProbabilities = classProbabilities.mapValues { $0 / totalProbability }

            if let bestClass = normalizedProbabilities.max(by: { a, b in a.value < b.value }) {
                let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(bestClass.key))
                let resultString = "\(predictedLabel) mit Wahrscheinlichkeit: \(String(format: "%.2f", bestClass.value * 100))%"
                return resultString
            }
            
            let predictedLabel = LabelMapper.getLabel(for: Int(prediction.label))
            
            
            return predictedLabel
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
    
    func classifyRfFullFeatures(features: SensorFeaturesAllLabel) -> String? {
        do {
            let input = RFInput(
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
            let classProbabilities = prediction.classProbability
            let totalProbability = classProbabilities.values.reduce(0, +)

            // Normiere die Wahrscheinlichkeiten
            let normalizedProbabilities = classProbabilities.mapValues { $0 / totalProbability }

            if let bestClass = normalizedProbabilities.max(by: { a, b in a.value < b.value }) {
                let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(bestClass.key))
                let resultString = "\(predictedLabel) mit Wahrscheinlichkeit: \(String(format: "%.2f", bestClass.value * 100))%"
                return resultString
            }
            
            
            let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(prediction.classLabel))
            
            return predictedLabel
        } catch{
            print("Prediction error: \(error)")
            return nil
        }
        
    }
    
    
    func classifyDecisionTree(features: SensorFeaturesAllLabel) -> String? {
        do {
            let input = DecisionTreeInput(
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
            
            let prediction = try decisionTree.prediction(input: input)
            let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(prediction.classLabel))
            
            
            let classProbabilities = prediction.classProbability
            
            if let bestClass = classProbabilities.max(by: { a, b in a.value < b.value }) {
                let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(bestClass.key))
                let resultString = "\(predictedLabel) mit Wahrscheinlichkeit: \(String(format: "%.2f", bestClass.value * 100))%"
        
                return resultString
            }
            
            return predictedLabel
            
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
    
    func classifyKnn(features: ScaledFeature) -> String? {
        
        let featureValues: [Float] = [
            Float(features.pitch_min),
            Float(features.gravityAccelZ_max),
            Float(features.gravityAccelY_max),
            Float(features.rotationRateZ_std),
            Float(features.gravityAccelZ_min),
            Float(features.rotationRateZ_max),
            Float(features.accelerationY_max),
            Float(features.roll_min),
            Float(features.roll_std),
            Float(features.gravityAccelX_min)
        ]
        
        
        do {
            let mlArray = try MLMultiArray(shape: [10], dataType: .float32)
            
            for (index, value) in featureValues.enumerated() {
                mlArray[index] = NSNumber(value: value)
            }
            let input = KnnInput(input: mlArray)
            
            let prediction = try knn.prediction(input: input)
            
            
            let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(prediction.classLabel))
            
      
            
            return predictedLabel
            
            
        } catch {
            print("Fehler bei der Klassifikation: \(error)")
            return nil
        }
    }
    
    func classifySvm(features: ScaledFeature) -> (String?, String?) {
        
        
        let input = SVCInput(
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
        
        let prediction = try? svm.prediction(input: input)
        let predictedLabel = LabelMapper.getLabelAllLabel(for: Int(prediction?.classLabel ?? 0))

        
        var resultString: String? = nil
            
            if let classProbabilities = prediction?.classProbability {
                if let (bestClass, bestProbability) = classProbabilities.max(by: { a, b in a.value < b.value }) {
                    let bestLabel = LabelMapper.getLabelAllLabel(for: Int(bestClass))
                    resultString = "\(bestLabel) mit Wahrscheinlichkeit: \(String(format: "%.2f", bestProbability * 100))%"
                }
            }
            
            return (predictedLabel, resultString)
        
        
    }
}
