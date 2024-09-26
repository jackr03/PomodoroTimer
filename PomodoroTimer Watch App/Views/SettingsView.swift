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
    @Bindable private var settingsViewModel = SettingsViewModel.shared
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    @AppStorage("dailyTarget") private var dailyTarget: Int = 12
    @AppStorage("autoContinue") private var autoContinue: Bool = false
    
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
                    .onChange(of: workDuration) {
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
                    .onChange(of: shortBreakDuration) {
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
                    .onChange(of: longBreakDuration) {
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
                    .onChange(of: dailyTarget) {
                        syncSettings()
                    }
                }
                
                Section {
                    Toggle("Auto-continue", isOn: $autoContinue)
                        .onChange(of: autoContinue) {
                            syncSettings()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                    
                if !settingsViewModel.settingsAreAllDefault {
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
        .onAppear() {
            syncSettings()
        }
    }
    
    // MARK: - Private functions
    private func syncSettings() {
        settingsViewModel.syncSettings()
        settingsViewModel.updateTimer()
    }
    
    private func resetToDefault() {
        settingsViewModel.resetSettings()
        settingsViewModel.syncSettings()
        Haptics.playClick()
        
        dismiss()
    }
}

#Preview {
    SettingsView()
}
