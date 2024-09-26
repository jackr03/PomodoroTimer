//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class SettingsViewModel {
    // MARK: - Properties
    static let shared = SettingsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    
    var settingsAreAllDefault: Bool = true
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Computed properties
    func syncSettings() {
        settingsAreAllDefault = SettingsManager.checkIfSettingsAreAllDefault()
    }
    
    // MARK: - Functions
    func fetchCurrentSettings() -> [String: Any] {
        return SettingsManager.fetchCurrentSettings()
    }
    
    func resetSettings() {
        SettingsManager.resetSettings()
    }
    
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
}
