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
    
    private let timer = PomodoroTimer.shared
    private let dataStore = DataStoreService.shared
    private let notifier = NotificationsManager.shared
    private let settings = SettingsManager.shared
    
    public var settingsAreAllDefault = true
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Computed properties
    var isPermissionGranted: Bool { notifier.permissionsGranted ?? true }
    
    // MARK: - Functions
    func syncSettings() {
        settingsAreAllDefault = settings.checkIfAllDefault()
    }
    
    func resetSettings() {
        settings.resetAll()
        updateRecordDailyTarget(to: settings.get(.dailyTarget))
        syncSettings()
    }
    
    func updateRecordDailyTarget(to value: Int) {
        let record = dataStore.fetchRecordToday()
        record.dailyTarget = value
    }
    
    func updateTimer() {
        guard !timer.isTimerTicking && !timer.isSessionInProgress else { return }
        
        timer.resetTimer()
    }
}
