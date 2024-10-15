//
//  Settings.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation

protocol Setting: CaseIterable where T: Equatable {
    associatedtype T
    
    var rawValue: String { get }
    var currentValue: T { get }
    var defaultValue: T { get}
    var isDefault: Bool { get }
    func reset()
}

extension Setting {
    // MARK: - Computed properties
    var isDefault: Bool { currentValue == defaultValue }
    
    // MARK: - Functions
    func reset() {
        UserDefaults.standard.set(defaultValue, forKey: rawValue)
    }
}

enum NumberSetting: String, Setting {
    // MARK: - Cases
    case workDuration
    case shortBreakDuration
    case longBreakDuration
    case dailyTarget
    
    // MARK: - Computed properties
    var currentValue: Int {
        let storedValue = UserDefaults.standard.integer(forKey: rawValue)
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
}

enum ToggleSetting: String, Setting {
    // MARK: - Cases
    case autoContinue
    
    // MARK: - Computed properties
    var currentValue: Bool { UserDefaults.standard.bool(forKey: rawValue) }
    
    var defaultValue: Bool {
        switch self {
        case .autoContinue: return true
        }
    }
}
