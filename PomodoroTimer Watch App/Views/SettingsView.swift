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
    
    @State var settingsAreAllDefault = false
    @State private var workDurationInMinutes: Int = 25
    @State private var shortBreakDurationInMinutes: Int = 5
    @State private var longBreakDurationInMinutes: Int = 30
    @State private var dailyTarget: Int = 12
    @AppStorage("autoContinue") private var autoContinue: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $workDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Work")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: workDurationInMinutes) { _, newValue in
                        update(.workDuration, to: newValue)
                    }
                    
                    Picker(selection: $shortBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Short break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: shortBreakDurationInMinutes) { _, newValue in
                        update(.shortBreakDuration, to: newValue)
                    }
                    
                    Picker(selection: $longBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Long break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: longBreakDurationInMinutes) { _, newValue in
                        update(.longBreakDuration, to: newValue)
                    }
                }
                
                Section {
                    Picker(selection: $dailyTarget) {
                        ForEach(1...24, id: \.self) {
                            Text("^[\($0) \("session")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Daily target")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: dailyTarget) { _, newValue in
                        update(.dailyTarget, to: newValue)
                    }
                }
                
                Section {
                    Toggle("Auto-continue", isOn: $autoContinue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                    
                if !settingsAreAllDefault {
                    Section {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                resetToDefault()
                            }) {
                                Text("Reset to default")
                                    .padding()
                                    .font(.callout)
                                    .foregroundStyle(.red)
                                    .background(.red.secondary)
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            // Sync view with UserDefault values
            syncSettings()
        }
    }
    
    private func update(_ setting: SettingsViewModel.SettingsType, to value: Int) {
        settingsViewModel.updateSetting(setting, to: value)
        syncSettings()
    }
    
    /**
     Update client-side settings using settingsViewModel
     Add a minor delay before checking if settingsAreAllDefault as it takes a non-negligible amount of time to write to UserDefaults
     */
    private func syncSettings() {
        (workDurationInMinutes, shortBreakDurationInMinutes, longBreakDurationInMinutes, dailyTarget) = settingsViewModel.fetchCurrentSettings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settingsAreAllDefault = settingsViewModel.settingsAreAllDefault
        }
    }
    
    private func resetToDefault() {
        settingsViewModel.resetSettings()
        settingsViewModel.playClickHaptic()
        
        syncSettings()
        dismiss()
    }
}

#Preview {
    SettingsView()
}
