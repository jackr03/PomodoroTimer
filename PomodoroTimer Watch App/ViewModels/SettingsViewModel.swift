//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import WatchKit

final class SettingsViewModel {
    // MARK: - Properties
    static let shared = SettingsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    private let settings: [any Setting] = NumericSetting.allCases + ToggleSetting.allCases
    
    private init() {}
    
    // MARK: - Computed properties
    // TODO: Make this observable so syncSettings() doesn't need to be called everytime (see PomodoroViewModel.showingFinishedAlert)
    var settingsAreAllDefault: Bool {
        return SettingsManager.settingsAreAllDefault
    }
    
    // MARK: - Functions
    // TODO: Move underlying logic into SettingsManager
    func fetchCurrentSettings() -> [String: Any] {
        return SettingsManager.fetchCurrentSettings()
    }
    
    func resetSettings() {
        SettingsManager.resetSettings()
    }
    
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
}
