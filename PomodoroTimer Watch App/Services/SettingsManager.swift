//
//  SettingsManager.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 15/10/2024.
//

import Foundation

final class SettingsManager {
    
    // MARK: - Singleton instance
    public static let shared = SettingsManager()
    
    // MARK: - Stored properties
    private static let mockSuiteName = "com.jackr03.PomodoroTimer.mockUserDefaults"

    private let settings: [any Setting] = IntSetting.allCases + BoolSetting.allCases
    
    public let userDefaults: UserDefaults
    
    // MARK: - Inits
    private init() {
        #if DEBUG
        self.userDefaults = UserDefaults(suiteName: SettingsManager.mockSuiteName)!
        self.userDefaults.removePersistentDomain(forName: SettingsManager.mockSuiteName)
        #else
        self.userDefaults = .standard
        #endif
    }
    
    // MARK: - Functions
    func get(_ setting: IntSetting) -> Int {
        return setting.currentValue(using: userDefaults)
    }
    
    func getDefault(_ setting: IntSetting) -> Int {
        return setting.defaultValue
    }
    
    func get(_ setting: BoolSetting) -> Bool {
        return setting.currentValue(using: userDefaults)
    }
    
    func getDefault(_ setting: BoolSetting) -> Bool {
        return setting.defaultValue
    }
    
    func checkIfAllDefault() -> Bool {
        return settings.allSatisfy { setting in
            setting.isDefault(using: userDefaults)
        }
    }
        
    func resetAll() {
        settings.forEach { setting in
            setting.reset(using: userDefaults)
        }
    }
}
