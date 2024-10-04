//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import SwiftUI

struct MissingPermissionView: View {
    // MARK: - Properties
    @Binding var showingPermissionsAlert: Bool
    
    // MARK: - Views
    var body: some View {
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
}

struct NumberPicker: View {
    // MARK: - Properties
    let label: String
    @Binding var selection: Int
    let range: ClosedRange<Int>
    let unit: String
    let tagModifier: (Int) -> Int
    let onChange: () -> Void
    
    // MARK: - Views
    var body: some View {
        Picker(selection: $selection) {
            ForEach(range, id: \.self) {
                Text("^[\($0) \(unit)](inflect: true)")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .tag(tagModifier($0))
            }
        } label: {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onChange(of: selection) {
            onChange()
        }
    }
}

struct TogglePicker: View {
    // Properties
    let label: String
    @Binding var isOn: Bool
    let onChange: () -> Void
    
    // MARK: - Views
    var body: some View {
        Toggle(label, isOn: $isOn)
            .onChange(of: isOn) {
                onChange()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

struct ResetSettingsButton: View {
    // MARK: - Properties
    let resetAction: () -> Void
    
    // MARK: - Views
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                resetAction()
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

    }
}

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
    
    // MARK: - Views
    var body: some View {
        NavigationStack {
            Form {
                if !settingsViewModel.isPermissionGranted {
                    Section {
                        MissingPermissionView(showingPermissionsAlert: $showingPermissionsAlert)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section {
                    NumberPicker(label: "Work",
                                   selection: $workDuration,
                                   range: 1...60,
                                   unit: "minute",
                                   tagModifier: { $0 * 60 },
                                   onChange: settingsViewModel.syncSettings
                    )
                    
                    NumberPicker(label: "Short break",
                                   selection: $shortBreakDuration,
                                   range: 1...60,
                                   unit: "minute",
                                   tagModifier: { $0 * 60 },
                                   onChange: settingsViewModel.syncSettings

                    )
                    
                    NumberPicker(label: "Long break",
                                   selection: $longBreakDuration,
                                   range: 1...60,
                                   unit: "minute",
                                   tagModifier: { $0 * 60 },
                                   onChange: settingsViewModel.syncSettings
                    )
                }
                
                Section {
                    NumberPicker(label: "Daily target",
                                 selection: $dailyTarget,
                                 range: 1...24,
                                 unit: "session",
                                 tagModifier: { $0 },
                                 onChange: settingsViewModel.syncSettings
                    )
                }
                
                Section {
                    TogglePicker(label: "Auto-continue",
                                 isOn: $autoContinue,
                                 onChange: settingsViewModel.syncSettings)
                }
                    
                if !settingsViewModel.settingsAreAllDefault {
                    Section {
                        ResetSettingsButton(resetAction: resetToDefault)
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
