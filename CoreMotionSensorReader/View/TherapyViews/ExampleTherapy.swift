//
//  ExampleTherapy.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 22.04.25.
//

import SwiftUI


private let exercies = ["Arm nach vorne",
                        "Arm nach oben",
                        "Knie kreiseln",
                        "Sitzendes Marschieren",
                        "Schnelle, tiefe Schritte",
                        "Gewicht verlagern"]


struct ExampleTherapy: View {
    
    @Bindable var watchReciever: WatchReciverController
    @Bindable var airpodscontroller: AirpodsDataController
    
    let soundservice = SoundService()
    
    @State private var selectedExercise: String = "Sitzendes Marschieren"
    
    @State private var lastUpdateTime: Date = Date()
    @State private var isActionTriggered: Bool = false
    
    @State private var isCountingDown = false
    @State private var countdown = 3
    @State private var calibrateTimer: Timer?
    
    @State private var trackBodyPosition: Bool = false

    
    var body: some View {
        VStack {
            Text("Übungsauswahl:")
                .font(.headline)
            pickerView
                
            VStack {

                Text("Erkannte Übung:")
                    .font(.headline)
                Text(watchReciever.svmLabelAll)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                if watchReciever.svmLabelAll == watchReciever.currentAcitivity {
                    Text("Korrekte Ausführung")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                        .padding(.top)
                        .transition(.opacity)
                } else {
                    Text("Falsche Ausführung")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .padding(.top)
                        .transition(.opacity)
                }
                
            
                if self.airpodscontroller.isAvailable || true {
                    Spacer()
                        .frame(minHeight: 10, idealHeight: 50, maxHeight: 500)
                        .fixedSize()
                    Text("AirPods Haltungserkennung:")
                        .font(.headline)
                    
                   
                    Toggle("Körperhaltung tracken", isOn: $airpodscontroller.isTrackingActive)
                        .padding()
                    Toggle("Kopfausrichtung tracken", isOn: $airpodscontroller.isHeadTrackingActive)
                        .padding()
                   
                    
                    Text("Körperhaltung \n \(airpodscontroller.posturePrediction)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                        .frame(height: 10)

                    Text("Kopfposition: \n \(airpodscontroller.prediction)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                
                }
               
            }
            .padding(.horizontal)
        }
        .onAppear {
            self.watchReciever.isSVMActive = true
            self.watchReciever.isTherapyViewActive = true
        }
        .onDisappear {
            self.watchReciever.isSVMActive = false
            self.airpodscontroller.isTrackingActive = false
            self.watchReciever.isTherapyViewActive = false
        }
    }
    
    private var pickerView: some View {
        Picker("Übung auswählen", selection: $watchReciever.currentAcitivity) {
            ForEach(exercies, id: \.self) { exercise in
                Text(exercise)
                    .font(.title3)
            }
        }
        
    }
}


#Preview {
    ExampleTherapy(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
