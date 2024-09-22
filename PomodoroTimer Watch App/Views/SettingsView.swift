//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    private let settingsViewModel = SettingsViewModel.shared

    @Bindable private var alertsViewModel = AlertsViewModel.shared
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    
    @State private var settingsHaveChanged = false
    @State private var workDurationInMinutes: Int = 25
    @State private var shortBreakDurationInMinutes: Int = 5
    @State private var longBreakDurationInMinutes: Int = 30
    
    var settingsAreDefault: Bool {
        let defaultWorkDurationInMinutes = 25
        let defaultShortBreakDurationInMinutes = 5
        let defaultLongBreakDurationInMinutes = 30
        
        return workDurationInMinutes == defaultWorkDurationInMinutes && shortBreakDurationInMinutes == defaultShortBreakDurationInMinutes && longBreakDurationInMinutes == defaultLongBreakDurationInMinutes
    }
    
    func updateDurations() {
        workDurationInMinutes = max(1, workDuration / 60)
        shortBreakDurationInMinutes = max(1, shortBreakDuration / 60)
        longBreakDurationInMinutes = max(1, longBreakDuration / 60)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Work", selection: $workDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: workDurationInMinutes) { _, newValue in
                        guard newValue != workDuration / 60 else { return }
                        
                        settingsViewModel.updateSetting(to: newValue, forKey: "workDuration")
                        settingsHaveChanged = true
                    }
                    
                    Picker("Short Break", selection: $shortBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: shortBreakDurationInMinutes) { _, newValue in
                        guard newValue != workDuration / 60 else { return }
                        
                        settingsViewModel.updateSetting(to: newValue, forKey: "shortBreakDuration")
                        settingsHaveChanged = true
                    }
                    
                    Picker("Long Break", selection: $longBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: longBreakDurationInMinutes) { _, newValue in
                        guard newValue != workDuration / 60 else { return }
                        
                        settingsViewModel.updateSetting(to: newValue, forKey: "longBreakDuration")
                        settingsHaveChanged = true
                    }
                    
                    if !settingsAreDefault {
                        Section {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    settingsViewModel.resetSettings()
                                    alertsViewModel.playPressedHaptic()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        updateDurations()
                                    }
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .padding()
                                        .frame(minWidth: 40, minHeight: 40)
                                        .font(.body)
                                        .foregroundStyle(.white)
                                        .background(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .cornerRadius(10)
                                
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .navigationTitle("Settings")
            }
        }
        .onAppear {
            // Update using AppStorage values when view appears
            updateDurations()
        }
        .alert("Time's up!", isPresented: $alertsViewModel.showAlert) {
            Button("OK") {
                alertsViewModel.stopHaptics()
            }
        }

    }
}

#Preview {
    SettingsView()
}
