//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    // TODO: - Determine if everything still needs to be a singleton
    private let settingsViewModel = SettingsViewModel.shared
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    @AppStorage("dailyTarget") private var dailyTarget: Int = 12
    @AppStorage("autoContinue") private var autoContinue: Bool = false
    
    @State var settingsAreAllDefault = false
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $workDuration) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0 * 60)
                        }
                    } label: {
                        Text("Work")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: workDuration) { _, _ in
                        syncSettings()
                    }
                    
                    Picker(selection: $shortBreakDuration) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0 * 60)
                        }
                    } label: {
                        Text("Short break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: shortBreakDuration) { _, _ in
                        syncSettings()
                    }
                    
                    Picker(selection: $longBreakDuration) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0 * 60)
                        }
                    } label: {
                        Text("Long break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: longBreakDuration) { _, _ in
                        syncSettings()
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
                    .onChange(of: dailyTarget) { _, _ in
                        syncSettings()
                    }
                }
                
                Section {
                    Toggle("Auto-continue", isOn: $autoContinue)
                        .onChange(of: autoContinue) { _, _ in
                            syncSettings()
                        }
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
    
    // MARK: - Private functions
    /**
     Update client-side settings using settingsViewModel
     Add a minor delay before checking if settingsAreAllDefault as it takes a non-negligible amount of time to write to UserDefaults
     */
    private func syncSettings() {
        (workDuration, shortBreakDuration, longBreakDuration, dailyTarget, autoContinue) = settingsViewModel.fetchCurrentSettings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settingsAreAllDefault = settingsViewModel.settingsAreAllDefault
        }
        
        settingsViewModel.updateTimer()
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
