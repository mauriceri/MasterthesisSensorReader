//
//  WatchAirPodsSensorView.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 27.12.24.
//

import SwiftUI

struct WatchAirPodsSensorView: View {
    
    @Bindable var watchReciever: WatchReciverController
    
    
    @Bindable var airpodscontroller = AirpodsDataController()
    
    
    
    @State private var debugMode = false
    
    @State private var showingPopover = false
    
    @State private var studyid: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var armlength: String = ""
    
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case studyid, height, age, armlength
    }
    
    enum WatchPositon {
        case left, right
    }
    
    @State private var selectedPosition: WatchPositon = .left
    
    
    @State private var exportFeatures = false
    
    
    
    let soundservice = SoundService()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            List {
                Section(header: Text("Persönliche Daten")) {
                    TextField(
                        "Kürzel",
                        text: $studyid
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .studyid)
                    .onSubmit {
                        focusedField = .height
                    }
                    
                    
                    TextField("Größe", text: $height)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .height)
                        .onSubmit {
                            focusedField = .age
                        }
                    
                    
                    TextField("Alter", text: $age)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .age)
                        .onSubmit {
                            focusedField = .armlength
                        }
                    
                    TextField("Armlänge", text: $armlength)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .armlength)
                        .onSubmit {
                            focusedField = nil
                        }
                }
                
                Toggle(isOn: $watchReciever.isSVMActive) {
                    Text("Zeige SVM")
                }
                
                if watchReciever.isSVMActive {
                    Text(watchReciever.svmLabelAll)
                }
                
            
                
                if airpodscontroller.isAvailable {
                    Section(header: Text("Kalibrierung")) {
                        Button("Kalibriere AirPods") {
                            if airpodscontroller.latestUncalibratedData != nil {
                                airpodscontroller.calibrate(data: airpodscontroller.latestUncalibratedData!)
                            }
                        }
                    }
                    
                }
                
                
                Section(header: Text("Daten-Export (CSV)")) {
                    
                    if(watchReciever.isCollectingTrainData) {
                        Text("Die Daten werden gesammelt. Nach erfolgreichem Abschluss des Sammelns werden die Exportoptionen wieder sichtbar. Verbleibende Zeit: \(watchReciever.timerSeconds)")
                            .foregroundStyle(Color.red)
                            .font(.headline)
                            .padding()
                        
                        Button("Timer Abbrechen") {
                            watchReciever.stopAllTimers()
                            airpodscontroller.stopAllTimers()
                        }
                        
                        Spacer()
                        
                    } else {
                        Button("Sitzend marschieren") {
                       
                                let filename = "watch_sitmarch_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                let filenamefeature = "watch_sitmarch_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"

                                watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                                
                                if(airpodscontroller.isAvailable) {
                                    let filename_airpods = "airpods_sitmarch_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                    airpodscontroller.startTimerAndExport(to: filename_airpods)
                                }
                            
                        }
                        Button("Sitzend marschieren") {
                            let filename = "watch_sitmarch_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_sitmarch_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_sitmarch_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                        Button("Arm nach vorne heben") {
                            let filename = "watch_armfrontraise_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_armfrontraise_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_armfrontraise_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                        Button("Gewicht verlagern mit Arm") {
                            let filename = "watch_weightdist_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_weightdist_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_weightdist_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                        Button("Knie kreisen") {
                            let filename = "watch_kneecircles_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_kneecircles_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_kneecircles_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                        Button("Schnelle tiefe Schritte") {
                            let filename = "watch_stepsdeepfast_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_stepsdeepfast_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_stepsdeepfast_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                        Button("Arm nach oben heben") {
                            let filename = "watch_armtopraise_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            let filenamefeature = "watch_armtopraise_feature_\(studyid)_\(height)_\(age)_\(armlength).csv"
                            watchReciever.startTimerAndExport(to: filename, to: filenamefeature)
                            
                            if airpodscontroller.isAvailable {
                                let filename_airpods = "airpods_armtopraise_\(studyid)_\(height)_\(age)_\(armlength).csv"
                                airpodscontroller.startTimerAndExport(to: filename_airpods)
                            }
                        }

                    }
                    
                    //  Text("HZ: \(watchReciever.receivedCount)")
                    Text("Datenmenge insgesamt (Uhr): \(watchReciever.getArraySize())")
                    Text("Datenmenge insgesamt (AirPods): \(airpodscontroller.getSensorDataAmount())")
                    Text("Datenmenge features (Uhr): \(watchReciever.getArraySize())")
                    
                    Text("Vergangene Zeit: \(String(format: "%.0f", watchReciever.getElapsedTime()))")
                    Spacer()
                    Button("Aktulles Array exprotieren") {
                        watchReciever.exportToCsv(to: "watch_alldata.csv")
                        
                        if (airpodscontroller.isAvailable) {
                            airpodscontroller.exportToCsv(to: "airpods_alldata.csv")
                        }
                    }
                    Spacer()
                    
                    Button("Daten löschen") {
                        watchReciever.clearData()
                        airpodscontroller.clearArray()
                    }
                }
                
                
                
                if (airpodscontroller.isAvailable) {
                    Section(header: Text("Bewegungserkennung AirPods")){
                        Text("Threshold: \(airpodscontroller.prediction)")
                        Text("Model: \(airpodscontroller.modelPrediction)")
                    }
                    
                    Section(header: Text("Ort des Sensors")){
                        Text("\(airpodscontroller.sensorlocation)")
                    }
                    
                }
                
                
                Section(header: Text("AirPods")) {
                    if(airpodscontroller.isAvailable) {
                        
                        Section(header: Text("Tools")){
                            Button("Export"){
                                airpodscontroller.exportToCsv(to: "airpodstest.csv")
                            }
                            
                            Button("Aktuelle Daten löschen") {
                                airpodscontroller.clearArray()
                            }
                            
                            Button("Verbindung erzwingen durch Ton") {
                                soundservice.playSound()
                            }
                            
                        }
                        
                    } else {
                        Text("AirPods-Daten nicht vefügbar. Versuche den Sound abzuspielen für das erzwingen der Verbindung").foregroundStyle(Color.red)
                        Button("Spiele Sound ab"){
                            soundservice.playSound()
                        }.clipShape(Capsule())
                    }
                }
                
                Toggle(isOn: $debugMode) {
                    Text("Debug Mode, Zeige Sensordaten an")
                }
                
                if (debugMode == true) {
                    DebugView(watchReciever: watchReciever, airpodscontroller: airpodscontroller)
                    
                }
            }
            
        }
        
    }
    
    
    
}


#Preview {
    WatchAirPodsSensorView(watchReciever: WatchReciverController())
}
