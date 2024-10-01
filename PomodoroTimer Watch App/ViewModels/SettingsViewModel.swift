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
    private let notificationService = NotificationService.shared
    
    var settingsAreAllDefault: Bool = true
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Computed properties
    var permissionsGranted: Bool {
        return notificationService.permissionsGranted ?? true
    }
    
    // MARK: - Functions
    func fetchCurrentSettings() -> [String: Any] {
        return SettingsManager.fetchCurrentSettings()
    }
    
    func syncSettings() {
        settingsAreAllDefault = SettingsManager.checkIfSettingsAreAllDefault()
    }
    
    func resetSettings() {
        SettingsManager.resetSettings()
    }
    
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
}
