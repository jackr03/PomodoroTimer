//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import WatchKit

final class SettingsViewModel {
    static let shared = SettingsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    private let settings: [any Setting] = NumericSetting.allCases + ToggleSetting.allCases
    
    private init() {}
    
    var settingsAreAllDefault: Bool {
        for setting in settings {
            if !setting.isDefault {
                return false
            }
        }
        
        return true
    }
    
    /**
     Return a tuple containing the current value for each setting type
     Convert into minutes if it is a durations setting
     
     TODO: Find a way to do this without hardcoding things
     */
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
    
    /**
     Update only if the timer isn't currently running.
     */
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
    
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
}
