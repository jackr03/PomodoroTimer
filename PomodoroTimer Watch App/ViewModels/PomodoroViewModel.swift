//
//  PomodoroViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

@Observable
final class PomodoroViewModel {
    
    // MARK: - Stored properties
    private let timer: PomodoroTimerProtocol
    private let repository: RecordRepositoryProtocol
    private let sessionManager = ExtendedRuntimeSessionManager()
    private let settingsManager = SettingsManager.shared
    private let notificationsManager = NotificationsManager()
    
    private(set) var cachedFormattedRemainingTime: String = "--:--"
    private(set) var cachedProgress: CGFloat = 1.0
    
    private var userDefaultsObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    
    // MARK: - Inits
    @MainActor
    init(
        timer: PomodoroTimerProtocol = PomodoroTimer(),
        repository: RecordRepositoryProtocol? = nil
    ) {
        self.timer = timer
        self.repository = repository ?? RecordRepository.shared
        
        updateCachedTimeAndProgress()
        observeSettingChanges()
    }
    
    // MARK: - Deinit
    deinit {
        if let userDefaultsObserver {
            NotificationCenter.default.removeObserver(userDefaultsObserver)
        }
    }
    
    // MARK: - Computed properties
    var formattedRemainingTime: String {
        if timer.remainingTime <= 0 {
            return "00:00"
        }
        
        let remainingTimeInMinutes = timer.remainingTime / 60
        let remainingTimeInSeconds = timer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
    }
    
    var progress: CGFloat {
        isSessionFinished ? 1.0 : CGFloat(timer.remainingTime) / CGFloat(timer.startingDuration)
    }
    
    var currentSession: String { timer.currentSession.rawValue }
    var sessionProgress: String {
        String(format: "%d/%d", timer.currentSessionNumber, timer.maxSessions)
    }
    
    // TODO: For use with skip, reset and stop
    var elapsedTime: Int { timer.startingDuration - timer.remainingTime }
    var isWorkSession: Bool { timer.currentSession == .work }
    var isTimerActive: Bool { timer.isTimerActive }
    var hasSessionStarted: Bool { timer.remainingTime != timer.startingDuration }
    var isSessionFinished: Bool { timer.isSessionFinished }
    
    /**
     True if nil (i.e. not determined) so that the warning is only shown when explicitly denied.
     */
    var isPermissionGranted: Bool { notificationsManager.permissionsGranted ?? true }
    
    // MARK: - Timer functions
    func startSession() {
        if notificationsManager.permissionsGranted == nil {
            notificationsManager.requestPermissions()
        }
        
        timer.startSession()
        startExtendedSession()
    }
        
    func pauseSession() {
        timer.pauseSession()
        stopExtendedSession()
    }
    
    /**
     Update record statistics and advance to next session.
     
     - Note: If auto-continue is enabled in the settings, also start a new session.
     */
    func completeSession() {
        updateRecord(incrementSessions: true, withTime: timer.startingDuration)
        timer.advanceToNextSession()
        stopExtendedSession()
        
        if settingsManager.get(.autoContinue) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.startSession()
            }
        }
    }
    
    func endPomodoroCycle() {
        updateRecord(withTime: elapsedTime)
        timer.reset()
        stopExtendedSession()
    }

    func resetSession() {
        updateRecord(withTime: elapsedTime)
        timer.resetSession()
    }
    
    func skipSession() {
        updateRecord(withTime: elapsedTime)
        pauseSession()
        timer.advanceToNextSession()
    }
    
    func startCachingTimeAndProgress() {
        updateCachedTimeAndProgress()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.updateCachedTimeAndProgress()
        }
    }
    
    func stopCachingTimeAndProgress() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    /**
     Checks session type and deducts time only if the current session is a break session.
     
     - Parameter seconds: The number of seconds to deduct from the remaining time.
     - Returns: The updated remaining time in session. Remains unchanged if the current session is a work session.
     */
    func deductBreakTime(by seconds: Int) -> Int {
        return isWorkSession ? timer.remainingTime : timer.deductTime(by: seconds)
    }

    /**
     Update record statistics if the current session is a work session.
     
     - Parameter incrementSessions: Whether to increment sessions or not
     - Parameter withTime: How much time to add to the Record
     */
    func updateRecord(incrementSessions: Bool = false,
                      withTime time: Int) {
        guard isWorkSession else { return }
        
        let record: Record
        
        if let existingRecord = repository.readRecord(byDate: Date.now) {
            record = existingRecord
        } else {
            record = Record()
            repository.createRecord(record)
        }
        
        if incrementSessions {
            record.incrementSessionsCompleted()
        }
        
        record.addTimeSpent(time)
    }
    
    // MARK: - Extended session functions
    func startExtendedSession() {
        sessionManager.startSession()
    }
    
    func stopExtendedSession() {
        sessionManager.stopSession()
    }
    
    // MARK: - Notification functions
    func notifyUserToResume() {
        guard isPermissionGranted && isWorkSession else { return }
        
        notificationsManager.notifyUserToResume()
    }
    
    func notifyUserWhenBreakOver() {
        guard isPermissionGranted && !isWorkSession else { return }
        
        let remainingTime = Double(timer.remainingTime)
        guard remainingTime > 0 else { return }

        notificationsManager.notifyUserWhenBreakOver(timeTilEnd: remainingTime)
    }
    
    func clearNotifications() {
        guard isPermissionGranted else { return }
        notificationsManager.clearNotifications()
    }
    
    // MARK: - Private functions
    private func updateCachedTimeAndProgress() {
        let remainingTimeInMinutes: Int = timer.remainingTime / 60
        let remainingTimeInSeconds: Int = timer.remainingTime % 60
        
        cachedFormattedRemainingTime = String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
        cachedProgress = isSessionFinished ? 1.0 : CGFloat(timer.remainingTime) / CGFloat(timer.currentSession.duration)
    }
    
    private func observeSettingChanges() {
        userDefaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSettingChanges()
        }
    }
    
    private func handleSettingChanges() {
        guard !isTimerActive && !hasSessionStarted else { return }
        timer.resetSession()
    }
}
