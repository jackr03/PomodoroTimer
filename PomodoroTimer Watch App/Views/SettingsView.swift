//
//  SettingsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 10/09/2024.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Stored properties
    private let hapticsManager = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    
    @State private var viewModel: SettingsViewModel
    @State private var showingPermissionsAlert: Bool = false
    
    @AppStorage(.workDuration) private var workDuration: Int
    @AppStorage(.shortBreakDuration) private var shortBreakDuration: Int
    @AppStorage(.longBreakDuration) private var longBreakDuration: Int
    @AppStorage(.dailyTarget) private var dailyTarget: Int
    @AppStorage(.autoContinue) private var autoContinue: Bool

    // MARK: - Inits
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        @Bindable var coordinator = coordinator
        
        ScrollView {
            if !viewModel.isPermissionGranted {
                missingPermissionView
            }
                
            sectionDivider(title: "Session Durations")

            numberPicker(label: "Work",
                         selection: $workDuration,
                         range: 1...60,
                         unit: "minute",
                         tagModifier: { $0 * 60 },
                         accessibilityIdentifier: "workDurationPicker")
                
            numberPicker(label: "Break",
                         selection: $shortBreakDuration,
                         range: 1...60,
                         unit: "minute",
                         tagModifier: { $0 * 60 },
                         accessibilityIdentifier: "shortBreakDurationPicker")
                
            numberPicker(label: "Long Break",
                         selection: $longBreakDuration,
                         range: 1...60,
                         unit: "minute",
                         tagModifier: { $0 * 60 },
                         accessibilityIdentifier: "longBreakDurationPicker")
                
            sectionDivider(title: "Other")
                
            numberPicker(label: "Daily Target",
                         selection: $dailyTarget,
                         range: 1...24,
                         unit: "session",
                         onChange: { newValue in viewModel.updateRecordDailyTarget(to: newValue) },
                         accessibilityIdentifier: "dailyTargetPicker"
            )
                
            toggleSwitch(label: "Auto-continue",
                             isOn: $autoContinue,
                             accessibilityIdentifier: "autoContinueSwitch")
                
            if !viewModel.settingsAreAllDefault {
                Divider()
                
                resetSettingsButton
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showingPermissionsAlert) {
            Alert(
                title: Text("Enable notifications"),
                message: Text("To receive notifications to resume your work sessions or when your break is over, please grant permission in the Settings app."),
                dismissButton: .default(Text("Dismiss"))
            )
        }
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
        Button(action: {
            viewModel.resetSettings()
            hapticsManager.playClick()
            
            coordinator.pop()
        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption)
            Text("Reset to default")
                .font(.caption)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .tint(.red)
        .padding()
        .accessibilityIdentifier("resetSettingsButton")
    }
    
    func sectionDivider(title: String) -> some View {
        Group {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            Divider()
        }
    }
    
    func numberPicker(
        label: String,
        selection: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String,
        tagModifier: @escaping (Int) -> Int = { $0 },
        onChange: ((Int) -> Void)? = nil,
        accessibilityIdentifier: String
    ) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Picker(label, selection: selection) {
                ForEach(range, id: \.self) {
                    Text("\($0)")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .tag(tagModifier($0))
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .frame(width: 60, height: 40)
            .accessibilityIdentifier(accessibilityIdentifier)
            .onChange(of: selection.wrappedValue) { _, newValue in
                onChange?(newValue)
            }
        }
        .padding()
    }
    
    func toggleSwitch(
        label: String,
        isOn: Binding<Bool>,
        onChange: ((Bool) -> Void)? = nil,
        accessibilityIdentifier: String
    ) -> some View {
        Toggle(label, isOn: isOn)
            .font(.body)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier(accessibilityIdentifier)
            .onChange(of: isOn.wrappedValue) { _, newValue in
                onChange?(newValue)
            }
            .padding()
    }
}

extension AppStorage {
    init(_ key: IntSetting) where Value == Int {
        self.init(wrappedValue: SettingsManager.shared.getDefault(key),
                  key.rawValue,
                  store: SettingsManager.shared.userDefaults)
    }
    
    init(_ key: BoolSetting) where Value == Bool {
        self.init(wrappedValue: SettingsManager.shared.getDefault(key),
                  key.rawValue,
                  store: SettingsManager.shared.userDefaults)
    }
}

#Preview {
    let viewModel = SettingsViewModel()
    let coordinator = NavigationCoordinator()
    
    SettingsView(viewModel: viewModel)
        .environment(coordinator)
}
