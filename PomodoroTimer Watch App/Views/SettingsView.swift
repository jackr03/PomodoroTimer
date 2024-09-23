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
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    
    @State private var workDurationInMinutes: Int = 25
    @State private var shortBreakDurationInMinutes: Int = 5
    @State private var longBreakDurationInMinutes: Int = 30
    
    @Environment(\.dismiss) private var dismiss
    
    var settingsAreDefault: Bool {
        let defaultWorkDurationInMinutes = 25
        let defaultShortBreakDurationInMinutes = 5
        let defaultLongBreakDurationInMinutes = 30
        
        return workDurationInMinutes == defaultWorkDurationInMinutes && shortBreakDurationInMinutes == defaultShortBreakDurationInMinutes && longBreakDurationInMinutes == defaultLongBreakDurationInMinutes
    }
    
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
                        settingsViewModel.updateSetting(to: newValue, forKey: "workDuration")
                    }
                    
                    Picker(selection: $shortBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Short Break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: shortBreakDurationInMinutes) { _, newValue in
                        settingsViewModel.updateSetting(to: newValue, forKey: "shortBreakDuration")
                    }
                    
                    Picker(selection: $longBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .tag($0)
                        }
                    } label: {
                        Text("Short Break")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: longBreakDurationInMinutes) { _, newValue in
                        settingsViewModel.updateSetting(to: newValue, forKey: "longBreakDuration")
                    }
                    
                    if !settingsAreDefault {
                        Section {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    settingsViewModel.resetSettings()
                                    settingsViewModel.playClickHaptic()
                                    
                                    dismiss()
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
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        
                    }
                }
                .navigationTitle("Settings")
            }
        }
        .onAppear {
            // Update using AppStorage values when view appears
            workDurationInMinutes = max(1, workDuration / 60)
            shortBreakDurationInMinutes = max(1, shortBreakDuration / 60)
            longBreakDurationInMinutes = max(1, longBreakDuration / 60)
        }
    }
}

#Preview {
    SettingsView()
}
