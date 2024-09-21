//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Bindable private var alertsViewModel = AlertsViewModel.shared
    private var settingsViewModel: SettingsViewModel
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    
    @State private var workDurationInMinutes: Int = 25
    @State private var shortBreakDurationInMinutes: Int = 5
    @State private var longBreakDurationInMinutes: Int = 30
    
    init(_ settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
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
                        settingsViewModel.updateSetting(to: newValue, forKey: "workDuration")
                    }
                    
                    Picker("Short break", selection: $shortBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: shortBreakDurationInMinutes) { _, newValue in
                        settingsViewModel.updateSetting(to: newValue, forKey: "shortBreakDuration")
                    }
                    
                    Picker("Long break", selection: $longBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: longBreakDurationInMinutes) { _, newValue in
                        settingsViewModel.updateSetting(to: newValue, forKey: "longBreakDuration")
                    }
                }
                .navigationTitle("Settings")
            }
        }
        .onAppear {
            // Update using AppStorage values when view appears
            // Set to 1 if < 60 seconds somehow
            workDurationInMinutes = max(1, workDuration / 60)
            shortBreakDurationInMinutes = max(1, shortBreakDuration / 60)
            longBreakDurationInMinutes = max(1, longBreakDuration / 60)
        }
        .alert("Time's up!", isPresented: $alertsViewModel.showAlert) {
            Button("OK") {
            }
        }

    }
}

#Preview {
    SettingsView(SettingsViewModel())
}
