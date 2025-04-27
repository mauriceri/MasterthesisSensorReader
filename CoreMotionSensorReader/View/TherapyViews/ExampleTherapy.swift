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
    
    @State private var selectedExercise: String = "Sitzendes Marschieren"
    
    @State private var lastUpdateTime: Date = Date()
    @State private var isActionTriggered: Bool = false

    
    var body: some View {
        VStack {
            VStack {
                
                pickerView
                    
                
                Text("Erkannte Übung")
                    .font(.headline)
                Text(watchReciever.svmLabelAll)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                if watchReciever.svmLabelAll == selectedExercise {
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
                
            
                if self.airpodscontroller.isAvailable {
                    Text("Körperhaltung: \(airpodscontroller.posturePrediction)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    Text("Kopfposition: \(airpodscontroller.prediction)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                
                }
                
                
                if isActionTriggered {
                    Text("Auf Ausführung achten!")
                        .foregroundColor(.red)
                        .font(.title)
                        .padding(.top)
                }
            }
            .padding(.horizontal)
            .onChange(of: watchReciever.svmLabelAll) { oldValue, newValue in
                handleSvmLabelChange(newValue)
            }
        }
        .onAppear {
            self.watchReciever.isSVMActive = true
        }
        .onDisappear {
            self.watchReciever.isSVMActive = false
        }
    }
    
    private var pickerView: some View {
        Picker("Übung auswählen", selection: $selectedExercise) {
            ForEach(exercies, id: \.self) { exercise in
                Text(exercise)
                    .font(.title3)
            }
        }.pickerStyle(.wheel)
        
    }
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 0.1, on: .main, in: .common)
    }
    
    private func handleSvmLabelChange(_ newValue: String) {
        if newValue != selectedExercise {
            let timeDifference = Date().timeIntervalSince(lastUpdateTime)
            if timeDifference > 1 {
                if !isActionTriggered {
                    isActionTriggered = true
                    watchReciever.sendHapticFeedback()
                }
            }
        } else {
            lastUpdateTime = Date()
            isActionTriggered = false
        }
    }
}


#Preview {
    ExampleTherapy(watchReciever: WatchReciverController(), airpodscontroller: AirpodsDataController())
}
