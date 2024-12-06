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
    private let repository: RecordRepositoryProtocol
    
    private let settingsManager = SettingsManager.shared
    private let notificationsManager = NotificationsManager()
    
    var settingsAreAllDefault = true
    
    // MARK: - Inits
    @MainActor
    init(repository: RecordRepositoryProtocol? = nil) {
        self.repository = repository ?? RecordRepository.shared
    }
    
    // MARK: - Computed properties
    var isPermissionGranted: Bool { notificationsManager.permissionsGranted ?? true }
    
    // MARK: - Functions
    func syncSettings() {
        settingsAreAllDefault = settingsManager.checkIfAllDefault()
    }
    
    func resetSettings() {
        settingsManager.resetAll()
        updateRecordDailyTarget(to: settingsManager.get(.dailyTarget))
        syncSettings()
    }
    
    func updateRecordDailyTarget(to value: Int) {
        if let record = repository.readRecord(byDate: Date.now) {
            record.dailyTarget = value
        }
    }
}
