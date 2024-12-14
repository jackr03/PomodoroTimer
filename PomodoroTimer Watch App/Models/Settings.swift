//
//  Settings.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation

protocol Setting: RawRepresentable, CaseIterable where RawValue == String, T: Equatable {
    associatedtype T
    
    var defaultValue: T { get }
    func currentValue(using userDefaults: UserDefaults) -> T
    func isDefault(using userDefaults: UserDefaults) -> Bool
    func isStored(using userDefaults: UserDefaults) -> Bool
    func reset(using userDefaults: UserDefaults)
}

extension Setting {
    func isDefault(using userDefaults: UserDefaults) -> Bool {
        return currentValue(using: userDefaults) == defaultValue
    }
    
    func isStored(using userDefaults: UserDefaults) -> Bool {
        if userDefaults.object(forKey: rawValue) != nil {
            return true
        } else {
            userDefaults.set(defaultValue, forKey: rawValue)
            return false
        }
    }
    
    func reset(using userDefaults: UserDefaults) {
        userDefaults.set(defaultValue, forKey: rawValue)
    }
}

enum IntSetting: String, Setting {
    
    case workDuration, shortBreakDuration, longBreakDuration, dailyTarget
    
    var defaultValue: Int {
        switch self {
        case .workDuration: return 1500
        case .shortBreakDuration: return 300
        case .longBreakDuration: return 1800
        case .dailyTarget: return 8
        }
    }
    
    func currentValue(using userDefaults: UserDefaults) -> Int {
        return isStored(using: userDefaults) ? userDefaults.integer(forKey: rawValue) : defaultValue
    }
}

enum BoolSetting: String, Setting {

    case autoContinue
    
    var defaultValue: Bool {
        switch self {
        case .autoContinue: return true
        }
    }
    
    func currentValue(using userDefaults: UserDefaults) -> Bool {
        return isStored(using: userDefaults) ? userDefaults.bool(forKey: rawValue) : defaultValue
    }
}
