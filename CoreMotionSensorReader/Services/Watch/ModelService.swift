//
//  ModelService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 11.03.25.
//

import Foundation
import CoreML

class ModelService {
    let model: Testmodel
    
    init?() {
        do {
            self.model = try Testmodel(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }

    func classify(features: [Double]) -> String? {
        do {
            // Überprüfen, ob die skalierten Features korrekt übergeben wurden
            guard features.count == 4 else {
                print("Fehler: Es wurden nicht alle erforderlichen skalierten Features übergeben.")
                return nil
            }
            
            // Erstelle das Input für das Modell mit den skalierten Features
            let input = TestmodelInput(
                gyro_squared: features[0],        // sumOfSquaresPitchYawRoll
                pitch_filtered: features[1],      // pitch
                accelerationX_filtered: features[2],  // accelerationX
                acc_squared: features[3]          // sumOfSquaresAccel
            )

            // Modellvorhersage durchführen
            let prediction = try model.prediction(input: input)
            print("Prediction label: \(prediction.label)")  // Ausgabe der Vorhersage
            return prediction.label
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }


}
