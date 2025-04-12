//
//  LabelMapper.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 08.04.25.
//


class LabelMapper {
    static let labelMapping: [Int: String] = [
        0: "Knie Kreiseln",
        1: "Sitzendes marschieren",
        2: "Schnelle tiefe Schritte",
        3: "Gewichtverlagern"
    ]
    
    static func getLabel(for prediction: Int) -> String {
        return labelMapping[prediction] ?? "Unknown"
    }
    
    static func getLabelAllLabel(for prediction: Int) -> String {
        return labelMappingAllLabel[prediction] ?? "Unknown"
    }
    
    
    static let labelMappingAllLabel: [Int: String] = [
        0: "Arm nach vorne",
        1: "Arm nach obeb",
        2: "Knie kreiseln",
        3: "Sitzendes marschieren",
        4: "Schnelle tiefe Scrhitte",
        5: "Gewichtverlagern"
        ]
        
}
