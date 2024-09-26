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
        for setting in settings {
            if !setting.isDefault {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Functions
    // TODO: Find a way to do this without hardcoding things
    // TODO: Move underlying logic into SettingsManager
    func fetchCurrentSettings() -> (Int, Int, Int, Int, Bool) {
        let workDurationInMinutes = NumericSetting.workDuration.currentValue
        let shortBreakDurationInMinutes = NumericSetting.shortBreakDuration.currentValue
        let longBreakDurationInMinutes = NumericSetting.longBreakDuration.currentValue
        let dailyTarget = NumericSetting.dailyTarget.currentValue
        
        let autoContinue = ToggleSetting.autoContinue.currentValue
        
        return (workDurationInMinutes, shortBreakDurationInMinutes, longBreakDurationInMinutes, dailyTarget, autoContinue)
    }
    
    func resetSettings() {
        for setting in settings {
            setting.reset()
        }
    }
    
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
}
