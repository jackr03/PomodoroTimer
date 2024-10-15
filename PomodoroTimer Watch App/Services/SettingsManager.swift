//
//  SettingsManager.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 15/10/2024.
//

import Foundation

final class SettingsManager {
    // MARK: - Properties
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard
    private let settings: [any Setting] = NumberSetting.allCases + ToggleSetting.allCases
        
    // MARK: - Inits
    private init() {}
    
    // MARK: - Functions
    func get(_ setting: NumberSetting) -> Int {
        return setting.currentValue
    }
    
    func get(_ setting: ToggleSetting) -> Bool {
        return setting.currentValue
    }
    
    func checkIfAllDefault() -> Bool {
        return settings.allSatisfy(\.isDefault)
    }
        
    func resetAll() {
        settings.forEach { setting in
            setting.reset()
        }
    }
}
