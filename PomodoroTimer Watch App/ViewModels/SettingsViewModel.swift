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
    
    private init() {}
    
    enum SettingsType: String, CaseIterable {
        case workDuration
        case shortBreakDuration
        case longBreakDuration
        case dailyTarget
        
        var currentValue: Int {
            return UserDefaults.standard.integer(forKey: rawValue)
        }
        
        var defaultValue: Int {
            switch self {
            case .workDuration: return 1500
            case .shortBreakDuration: return 300
            case .longBreakDuration: return 1800
            case .dailyTarget: return 12
            }
        }
        
        var isDurationSetting: Bool {
            switch self {
            case .workDuration, .shortBreakDuration, .longBreakDuration:
                return true
            default:
                return false
            }
        }
        
        func update(to value: Int) {
            UserDefaults.standard.set(value, forKey: rawValue)
        }
        
        func reset() {
            UserDefaults.standard.set(defaultValue, forKey: rawValue)
        }
    }
    
    var settingsAreAllDefault: Bool {
        for setting in SettingsType.allCases {
            if setting.currentValue != setting.defaultValue {
                return false
            }
        }
        
        return true
    }
    
    /**
     Return a tuple containing the current value for each setting type
     Convert into minutes if it is a durations setting
     */
    func fetchCurrentSettings() -> (Int, Int, Int, Int) {
        let workDurationInMinutes = SettingsType.workDuration.currentValue / 60
        let shortBreakDurationInMinutes = SettingsType.shortBreakDuration.currentValue / 60
        let longBreakDurationInMinutes = SettingsType.longBreakDuration.currentValue / 60
        let dailyTarget = SettingsType.dailyTarget.currentValue
        
        return (workDurationInMinutes, shortBreakDurationInMinutes, longBreakDurationInMinutes, dailyTarget)
    }

    func updateSetting(_ setting: SettingsType, to value: Int) {
        if setting.isDurationSetting {
            let valueInSeconds = value * 60
            setting.update(to: valueInSeconds)
            
            updateTimer()
        } else {
            setting.update(to: value)
        }
    }
    
    func resetSettings() {
        for setting in SettingsType.allCases {
            setting.reset()
        }
        
        updateTimer()
    }
    
    /**
     Update only if the timer isn't currently running.
     */
    private func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
    
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
}
