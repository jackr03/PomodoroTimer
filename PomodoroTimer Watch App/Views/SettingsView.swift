//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @Bindable private var settingsViewModel = SettingsViewModel.shared
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    @AppStorage("dailyTarget") private var dailyTarget: Int = 12
    @AppStorage("autoContinue") private var autoContinue: Bool = false
    
    @State private var showingPermissionsAlert: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                if !settingsViewModel.permissionsGranted {
                    Section {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.yellow)
                            
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                
                                Button(action: {
                                    showingPermissionsAlert = true
                                }) {
                                    Text("Permissions required for full functionality. Tap for details.")
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            }
                            .padding()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                
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
                        settingsViewModel.syncSettings()
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
                        settingsViewModel.syncSettings()
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
                        settingsViewModel.syncSettings()
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
                        settingsViewModel.syncSettings()
                    }
                }
                
                Section {
                    Toggle("Auto-continue", isOn: $autoContinue)
                        .onChange(of: autoContinue) {
                            settingsViewModel.syncSettings()
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    settingsViewModel.updateTimer()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                .handGestureShortcut(.primaryAction)
            }
        }
        .onAppear() {
            settingsViewModel.syncSettings()
        }
        .onChange(of: settingsViewModel.isSessionFinished) { _, isFinished in
            if isFinished {
                dismiss()
            }
        }
        .alert(isPresented: $showingPermissionsAlert) {
            Alert(
                title: Text("Enable notifications"),
                message: Text("To receive notifications to resume your work sessions or when your break is over, please grant permission in the Settings app."),
                dismissButton: .default(Text("Dismiss"))
            )
        }
    }
    
    // MARK: - Private functions
    private func resetToDefault() {
        settingsViewModel.resetSettings()
        settingsViewModel.updateTimer()
        Haptics.playClick()
        
        dismiss()
    }
}

#Preview {
    SettingsView()
}
