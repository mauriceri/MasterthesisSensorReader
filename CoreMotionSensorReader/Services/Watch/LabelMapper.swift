//
//  LabelMapper.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 08.04.25.
//


class LabelMapper {
    static let labelMapping: [Int: String] = [
        0: "Knie kreiseln",
        1: "Sitzendes Marschieren",
        2: "Schnelle, tiefe Schritte",
        3: "Gewicht verlagern"
    ]
    
    static func getLabel(for prediction: Int) -> String {
        return labelMapping[prediction] ?? "Unknown"
    }
    
    static func getLabelAllLabel(for prediction: Int) -> String {
        return labelMappingAllLabel[prediction] ?? "Unknown"
    }
    
    static let labelMappingAllLabel: [Int: String] = [
        0: "Arm nach vorne",
        1: "Arm nach oben",
        2: "Knie kreiseln",
        3: "Sitzendes Marschieren",
        4: "Schnelle, tiefe Schritte",
        5: "Gewicht verlagern"
    ]
}
