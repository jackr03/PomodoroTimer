//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Stored properties
    @State private var viewModel: SettingsViewModel
    private let haptics = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    
    @AppStorage(.workDuration) private var workDuration: Int = SettingsManager.shared.getDefault(.workDuration)
    @AppStorage(.shortBreakDuration) private var shortBreakDuration: Int = SettingsManager.shared.getDefault(.shortBreakDuration)
    @AppStorage(.longBreakDuration) private var longBreakDuration: Int = SettingsManager.shared.getDefault(.longBreakDuration)
    @AppStorage(.dailyTarget) private var dailyTarget: Int = SettingsManager.shared.getDefault(.dailyTarget)
    @AppStorage(.autoContinue) private var autoContinue: Bool = SettingsManager.shared.getDefault(.autoContinue)
    
    @State private var showingPermissionsAlert: Bool = false
    
    // MARK: - Inits
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var coordinator = coordinator
        
        Form {
            if !viewModel.isPermissionGranted {
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
                             onChange: { newValue in viewModel.updateRecordDailyTarget(to: newValue) }
                )
            }
            
            Section {
                togglePicker(label: "Auto-continue", isOn: $autoContinue)
            }
             
            if !viewModel.settingsAreAllDefault {
                Section {
                    resetSettingsButton
                        .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden(true)
        // TODO: Handle updating timer differently
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewModel.updateTimer()
                    coordinator.pop()
                }) {
                    Image(systemName: "chevron.left")
                }
                .handGestureShortcut(.primaryAction)
            }
        }
        .onAppear() {
            viewModel.syncSettings()
        }
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
        HStack {
            Button(action: {
                viewModel.resetSettings()
                viewModel.updateTimer()
                haptics.playClick()
                
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
        }
    }
    
    // TODO: Make picker open up on current selection
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
            viewModel.syncSettings()
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
                viewModel.syncSettings()
            }
    }
}

#Preview {
    let viewModel = SettingsViewModel()
    let coordinator = NavigationCoordinator()
    
    SettingsView(viewModel: viewModel)
        .environment(coordinator)
}
