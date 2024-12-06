//
//  SettingsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class SettingsViewModel {
    
    // MARK: - Stored properties
    private let settingsManager = SettingsManager.shared
    private let repository: RecordRepositoryProtocol
    private let notificationsManager = NotificationsManager()
    
    // MARK: - Inits
    @MainActor
    init(repository: RecordRepositoryProtocol? = nil) {
        self.repository = repository ?? RecordRepository.shared
    }
    
    // MARK: - Computed properties
    var settingsAreAllDefault: Bool { settingsManager.checkIfAllDefault() }
    var isPermissionGranted: Bool { notificationsManager.permissionsGranted ?? true }
    
    // MARK: - Functions
    /**
     Resets all settings, updating the target for today's record if needed.
     */
    func resetSettings() {
        settingsManager.resetAll()
        updateRecordDailyTarget(to: settingsManager.get(.dailyTarget))
    }
    
    func updateRecordDailyTarget(to value: Int) {
        if let record = repository.readRecord(byDate: Date.now) {
            record.dailyTarget = value
        }
    }
}
