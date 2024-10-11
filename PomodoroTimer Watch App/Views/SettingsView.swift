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
    
    @AppStorage("workDuration") private var workDuration: Int = NumberSetting.workDuration.defaultValue
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = NumberSetting.shortBreakDuration.defaultValue
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = NumberSetting.longBreakDuration.defaultValue
    @AppStorage("dailyTarget") private var dailyTarget: Int = NumberSetting.dailyTarget.defaultValue
    @AppStorage("autoContinue") private var autoContinue: Bool = ToggleSetting.autoContinue.defaultValue
    
    @State private var showingPermissionsAlert: Bool = false
    
    // MARK: - Views
    var body: some View {
        NavigationStack {
            Form {
                if !settingsViewModel.isPermissionGranted {
                    Section {
                        missingPermissionView
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section {
                    numberPicker(label: "Work",
                                 selection: $workDuration,
                                 range: 1...60,
                                 unit: "minute",
                                 tagModifier: { $0 * 60 })
                    
                    numberPicker(label: "Short break",
                                 selection: $shortBreakDuration,
                                 range: 1...60,
                                 unit: "minute",
                                 tagModifier: { $0 * 60 })
                    
                    numberPicker(label: "Long break",
                                 selection: $longBreakDuration,
                                 range: 1...60,
                                 unit: "minute",
                                 tagModifier: { $0 * 60 })
                }
                
                Section {
                    numberPicker(label: "Daily target",
                                 selection: $dailyTarget,
                                 range: 1...24,
                                 unit: "session",
                                 onChange: { newValue in settingsViewModel.updateRecordDailyTarget(to: newValue) }
                    )
                }
                
                Section {
                    togglePicker(label: "Auto-continue", isOn: $autoContinue)
                }
                 
                if !settingsViewModel.settingsAreAllDefault {
                    Section {
                        resetSettingsButton
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

private extension SettingsView {
    var missingPermissionView: some View {
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
    
    var resetSettingsButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                resetToDefault()
//                haptics
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
    
    func numberPicker(label: String,
                        selection: Binding<Int>,
                        range: ClosedRange<Int>,
                        unit: String,
                        tagModifier: @escaping (Int) -> Int = { $0 },
                        onChange: ((Int) -> Void)? = nil
    ) -> some View {
        Picker(selection: selection) {
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
        .onChange(of: selection.wrappedValue) { _, newValue in
            onChange?(newValue)
            settingsViewModel.syncSettings()
        }
    }
    
    func togglePicker(label: String,
                      isOn: Binding<Bool>,
                      onChange: ((Bool) -> Void)? = nil
    ) -> some View {
        Toggle(label, isOn: isOn)
            .font(.caption)
            .foregroundStyle(.secondary)
            .onChange(of: isOn.wrappedValue) { _, newValue in
                onChange?(newValue)
                settingsViewModel.syncSettings()
            }
    }
}

#Preview {
    SettingsView()
}
