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
    // MARK: - Properties
    static let shared = PomodoroViewModel()
    
    private let timer = PomodoroTimer.shared
    private let repository = RecordRepository.shared
    private let session = ExtendedRuntimeSessionManager.shared
    private let notifier = NotificationsManager.shared
    private let settings = SettingsManager.shared
    
    private(set) var cachedFormattedRemainingTime: String = ""
    private(set) var cachedProgress: CGFloat = 1.0
    
    private var updateTimer: Timer?
    private var hapticTimer: Timer?
    
    // MARK: - Init
    private init() {
        updateTimeAndProgress()
    }
    
    // MARK: - Computed properties
    var formattedRemainingTime: String {
        let remainingTimeInMinutes: Int = timer.remainingTime / 60
        let remainingTimeInSeconds: Int = timer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
    }
    
    var progress: CGFloat {
        CGFloat(timer.remainingTime) / CGFloat(timer.currentSession.duration)
    }
    
    var maxSessions: Int { timer.maxSessions }
    var currentSession: String { timer.currentSession.rawValue }
    var currentSessionsDone: Int { timer.currentSessionNumber }
    var isWorkSession: Bool { timer.isWorkSession }
    var isTimerTicking: Bool { timer.isTimerTicking }
    var isSessionFinished: Bool {
        get { return timer.isSessionFinished }
        set { timer.isSessionFinished = newValue }
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
        timer.pauseTimer(untilReopened)
        
        if !untilReopened {
            stopExtendedSession()
        }
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
        
        if settings.get(.autoContinue) {
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

    func incrementWorkSessionsCompleted() {
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
        session.startSession()
    }
    
    func stopExtendedSession() {
        session.stopSession()
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
        cachedProgress = CGFloat(timer.remainingTime) / CGFloat(timer.currentSession.duration)
    }
}
