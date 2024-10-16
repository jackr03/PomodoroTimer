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
    private let dataService = DataService.shared
    private let notificationService = NotificationService.shared
    
    public var settingsAreAllDefault = true
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Computed properties
    var isPermissionGranted: Bool { notificationService.permissionsGranted ?? true }
    var isSessionFinished: Bool { pomodoroTimer.isSessionFinished }
    
    // MARK: - Functions
    func syncSettings() {
        settingsAreAllDefault = SettingsManager.checkIfSettingsAreAllDefault()
    }
    
    func resetSettings() {
        SettingsManager.resetSettings()
        updateRecordDailyTarget(to: NumberSetting.dailyTarget.defaultValue)
        syncSettings()
    }
    
    func updateRecordDailyTarget(to value: Int) {
        let record = dataService.fetchRecordToday()
        record.dailyTarget = value
    }
    
    func updateTimer() {
        guard !pomodoroTimer.isTimerTicking && !pomodoroTimer.isSessionInProgress else { return }
        
        pomodoroTimer.resetTimer()
    }
}
