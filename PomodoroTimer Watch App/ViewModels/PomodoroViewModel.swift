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
        let remainingTimeInMinutes: Int = timer.remainingTime / 60
        let remainingTimeInSeconds: Int = timer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
    }
    
    var progress: CGFloat {
        isSessionFinished ? 1.0 : CGFloat(timer.remainingTime) / CGFloat(timer.currentSession.duration)
    }
    
    var currentSession: String { timer.currentSession.rawValue }
    var sessionProgress: String {
        String(format: "%d/%d", timer.currentSessionNumber, timer.maxSessions)
    }
    
    var isWorkSession: Bool { timer.currentSession == .work }
    var isTimerActive: Bool { timer.isTimerActive }
    var hasSessionStarted: Bool { timer.hasSessionStarted }
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
     Increment the number of sessions completed if the new session is NOT a work session, as that means
     we have just transitioned from one.
     
     - Note: If autoContinue is enabled in the settings, start a new session.
     */
    func completeSession() async {
        timer.advanceToNextSession()
        stopExtendedSession()
        
        if !isWorkSession {
            incrementSessionsCompleted()
        }
        
        if settingsManager.get(.autoContinue) {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.startSession()
        }
    }
    
    func endPomodoroCycle() {
        timer.reset()
        stopExtendedSession()
    }

    func resetSession() {
        timer.resetSession()
    }
    
    func skipSession() {
        self.pauseSession()
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

    func incrementSessionsCompleted() {
        if let record = repository.readRecord(byDate: Date.now) {
            record.sessionsCompleted += 1
        } else {
            let record = Record()
            record.sessionsCompleted += 1
            repository.createRecord(record)
        }
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
        guard !timer.isTimerActive && !timer.hasSessionStarted else { return }
        timer.resetSession()
    }
}
