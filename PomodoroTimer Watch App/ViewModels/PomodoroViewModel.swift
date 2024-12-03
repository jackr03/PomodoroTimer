//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class PomodoroViewModel {
    
    // MARK: - Stored properties
    private let timer: PomodoroTimer
    private let repository: RecordRepositoryProtocol
    
    private let sessionManager = ExtendedRuntimeSessionManager()
    private let settingsManager = SettingsManager.shared
    private let notifier = NotificationsManager.shared
    
    private(set) var cachedFormattedRemainingTime: String = ""
    private(set) var cachedProgress: CGFloat = 1.0
    
    private var userDefaultsObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    
    // MARK: - Inits
    @MainActor
    init(timer: PomodoroTimer = PomodoroTimer(),
         repository: RecordRepositoryProtocol? = nil
    ) {
        self.timer = timer
        self.repository = repository ?? RecordRepository.shared
        
        updateTimeAndProgress()
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
        CGFloat(timer.remainingTime) / CGFloat(timer.currentSessionDuration)
    }
    
    var maxSessions: Int { timer.maxSessions }
    var currentSession: String { timer.currentSession.rawValue }
    var currentSessionsDone: Int { timer.currentSessionNumber }
    var isWorkSession: Bool { timer.isWorkSession }
    var isTimerTicking: Bool { timer.isTimerTicking }
    var isSessionInProgress : Bool { timer.remainingTime != timer.currentSessionDuration }
    var isSessionFinished: Bool {
        get { return timer.isSessionFinished }
        set {
            // Increment count when !isWorkSession, as this means we have just transitioned from a work session
            if isSessionFinished && !timer.isWorkSession {
                incrementSessionsCompleted()
            }
            
            timer.isSessionFinished = newValue
        }
    }
    // Return true if not determined so that the warning is only shown when explicitly denied
    var isPermissionGranted: Bool { notifier.permissionsGranted ?? true }
    
    // MARK: - Timer functions
    func startTimer() {
        timer.startTimer()
        
        if notifier.permissionsGranted == nil {
            notifier.requestPermissions()
        }
        
        startExtendedSession()
    }
        
    func pauseTimer(untilReopened: Bool = false) {
        timer.pauseTimer()
        stopExtendedSession()
    }
    
    func endCycle() {
        timer.endCycle()
        stopExtendedSession()
    }

    func resetTimer() {
        timer.resetTimer()
    }
    
    func skipSession() {
        timer.skipSession()
        stopExtendedSession()
    }
    
    func prepareForNextSession() {
        isSessionFinished = false
        stopExtendedSession()
        
        if settingsManager.get(.autoContinue) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startTimer()
            }
        }
    }
    
    func startCachingTimeAndProgress() {
        updateTimeAndProgress()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.updateTimeAndProgress()
        }
    }
    
    func stopCachingTimeAndProgress() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func deductBreakTime(by seconds: Int) -> Int {
        guard !timer.isWorkSession else { return -1 }
        
        timer.deductTime(by: seconds)
        
        return timer.remainingTime
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
    func checkPermissions() {
        Task {
            await notifier.checkPermissions()
        }
    }
    
    func notifyUserToResume() {
        guard timer.isWorkSession else { return }
        
        notifier.notifyUserToResume()
    }
    
    func notifyUserWhenBreakOver() {
        guard !timer.isWorkSession else { return }
        
        let remainingTime = Double(timer.remainingTime)
        guard remainingTime > 0 else { return }

        notifier.notifyUserWhenBreakOver(timeTilEnd: remainingTime)
    }
    
    func clearNotifications() {
        notifier.clearNotifications()
    }
    
    // MARK: - Private functions
    private func updateTimeAndProgress() {
        let remainingTimeInMinutes: Int = timer.remainingTime / 60
        let remainingTimeInSeconds: Int = timer.remainingTime % 60
        
        cachedFormattedRemainingTime = String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
        cachedProgress = CGFloat(timer.remainingTime) / CGFloat(timer.currentSessionDuration)
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
        guard !timer.isTimerTicking && !timer.isSessionInProgress else { return }
        timer.resetTimer()
    }
}
