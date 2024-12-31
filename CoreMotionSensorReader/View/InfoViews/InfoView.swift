//
//  InfoView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 29.12.24.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        Text("""
        Diese App wurde im Rahmen meiner Masterthesis entwickelt. Sie dient dem Sammeln von Bewegungsdaten der Apple Watch und AirPods.

        ### Hinweise zur Nutzung:
        - Um Bewegungsdaten von der Apple Watch zu lesen, muss die App auf der Watch gestartet werden.
        - Tippe auf **"Starte Workout"**, um das Workout zu beginnen. Dies stellt sicher, dass die Datenaufzeichnung nicht unterbrochen wird.
        
        - Für das Aufzeichnen einer Übung auf den Übungsnamen klicken und die Übung durchführen für 30 Sekunden.

        ### Datenverwaltung:
        Die gesammelten Daten werden im App-Ordner als **CSV-Dateien** gespeichert.
        """)
    }
}

#Preview {
    InfoView()
}
