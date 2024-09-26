//
//  Settings.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation

// MARK: - Settings manager
// TODO: Implement reset and
struct SettingsManager {
    static let allSettings: [any Setting] = NumericSetting.allCases + ToggleSetting.allCases
    
    static var settingsAreAllDefault: Bool {
        for setting in allSettings {
            if !setting.isDefault {
                return false
            }
        }
        
        return true
    }
    
    static func fetchCurrentSettings() -> [String: Any] {
        var currentSettings: [String: Any] = [:]
        
        for setting in allSettings {
            currentSettings[setting.rawValue] = setting.currentValue
        }
        
        return currentSettings
    }
    
    static func resetSettings() {
        for setting in allSettings {
            setting.reset()
        }
    }
}

// MARK: - Setting protocol
protocol Setting: CaseIterable where T: Equatable {
    associatedtype T
    
    var rawValue: String { get }
    var currentValue: T { get }
    var defaultValue: T { get}
    var isDefault: Bool { get }
    func update(to value: T)
    func reset()
}

// MARK: - Setting extension to provide default implementations
extension Setting {
    var isDefault: Bool {
        return currentValue == defaultValue
    }
    
    func reset() {
        Defaults.set(rawValue, to: defaultValue)
    }
}

// MARK: - Integer value settings
enum NumericSetting: String, Setting {
    case workDuration
    case shortBreakDuration
    case longBreakDuration
    case dailyTarget
    
    var currentValue: Int {
        let storedValue = Defaults.getIntFrom(rawValue)
        return storedValue == 0 ? defaultValue: storedValue
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
        Defaults.set(rawValue, to: value)
    }
}

// MARK: - Boolean settings
enum ToggleSetting: String, Setting {
    case autoContinue
    
    var currentValue: Bool {
        return Defaults.getBoolFrom(rawValue)
    }
    
    var defaultValue: Bool {
        switch self {
        case .autoContinue: return false
        }
    }
    
    func update(to value: Bool) {
        Defaults.set(rawValue, to: value)
    }
}