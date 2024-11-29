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
    
    // MARK: - Stored properties
    // FIXME: Either pass in PomodoroTimer or figure out a way to send notifications
//    private let timer = PomodoroTimer.shared
    private let repository: RecordRepositoryProtocol
    
    private let notifier = NotificationsManager.shared
    private let settings = SettingsManager.shared
    
    public var settingsAreAllDefault = true
    
    // MARK: - Inits
    @MainActor
    init(repository: RecordRepositoryProtocol? = nil) {
        self.repository = repository ?? RecordRepository.shared
    }
    
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
        if let record = repository.readRecord(byDate: Date.now) {
            record.dailyTarget = value
        }
    }
    
    func updateTimer() {
//        guard !timer.isTimerTicking && !timer.isSessionInProgress else { return }
//        
//        timer.resetTimer()
    }
}
