//
//  Settings.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation

// MARK: - Settings manager
// TODO: Implement reset and

// MARK: - Setting protocol
protocol Setting: CaseIterable {
    associatedtype T
    
    var currentValue: T { get }
    var defaultValue: T { get}
    var isDefault: Bool { get }
    func update(to value: T)
    func reset()
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
    
    var isDefault: Bool {
        return currentValue == defaultValue
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
        UserDefaults.standard.set(value, forKey: rawValue)
    }
    
    func reset() {
        Defaults.set(rawValue, to: defaultValue)
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
    
    var isDefault: Bool {
        return currentValue == defaultValue
    }
    
    func update(to value: Bool) {
    
        Defaults.set(rawValue, to: value)
    }
    
    func reset() {
        Defaults.set(rawValue, to: defaultValue)
    }
}
