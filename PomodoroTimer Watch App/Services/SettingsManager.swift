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
    private let settings: [any Setting] = IntSetting.allCases + BoolSetting.allCases
        
    // MARK: - Inits
    private init() {}
    
    // MARK: - Functions
    func get(_ setting: IntSetting) -> Int {
        return setting.currentValue
    }
    
    func getDefault(_ setting: IntSetting) -> Int {
        return setting.defaultValue
    }
    
    func get(_ setting: BoolSetting) -> Bool {
        return setting.currentValue
    }
    
    func getDefault(_ setting: BoolSetting) -> Bool {
        return setting.defaultValue
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
