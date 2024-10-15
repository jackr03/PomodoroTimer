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
    
    private let pomodoroTimer = PomodoroTimer.shared
    private let dataService = DataService.shared
    private let extendedSessionService = ExtendedSessionService.shared
    private let notificationService = NotificationService.shared
    
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
        let remainingTimeInMinutes: Int = pomodoroTimer.remainingTime / 60
        let remainingTimeInSeconds: Int = pomodoroTimer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
    }
    
    var progress: CGFloat {
        CGFloat(pomodoroTimer.remainingTime) / CGFloat(pomodoroTimer.currentSession.duration)
    }
    
    var maxSessions: Int { pomodoroTimer.maxSessions }
    var currentSession: String { pomodoroTimer.currentSession.rawValue }
    var currentSessionsDone: Int { pomodoroTimer.currentSessionNumber }
    var isWorkSession: Bool { pomodoroTimer.isWorkSession }
    var isTimerTicking: Bool { pomodoroTimer.isTimerTicking }
    var isSessionFinished: Bool {
        get { return pomodoroTimer.isSessionFinished }
        set { pomodoroTimer.isSessionFinished = newValue }
    }
    // Return true if not determined so that the warning is only shown when explicitly denied
    var isPermissionGranted: Bool { notificationService.permissionsGranted ?? true }
    
    // MARK: - Timer functions
    func startTimer() {
        pomodoroTimer.startTimer()
        
        if notificationService.permissionsGranted == nil {
            notificationService.requestPermissions()
        }
        
        startExtendedSession()
    }
        
    func pauseTimer() {
        pomodoroTimer.pauseTimer()
        stopExtendedSession()
    }
    
    func endCycle() {
        pomodoroTimer.endCycle()
        stopExtendedSession()
    }

    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    func skipSession() {
        pomodoroTimer.skipSession()
        stopExtendedSession()
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
        guard !pomodoroTimer.isWorkSession else { return -1 }
        
        pomodoroTimer.deductTime(by: seconds)
        
        return pomodoroTimer.remainingTime
    }
    
    // TODO: Get using SettingsService
    func startTimerIfAutoContinueEnabled() {
        if SettingsManager.shared.get(.autoContinue) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startTimer()
            }
        }
    }
    
    func incrementWorkSessionsCompleted() {
        let record = dataService.fetchRecordToday()
        record.sessionsCompleted += 1
    }
    
    // MARK: - Haptic functions
    func playHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            Haptics.playStop()
        }
    }
    
    func stopHaptics() {
        if let hapticTimer = hapticTimer {
            hapticTimer.invalidate()
            self.hapticTimer = nil
        }

        isSessionFinished = false
        stopExtendedSession()
        startTimerIfAutoContinueEnabled()
    }
    
    // MARK: - Extended session functions
    func startExtendedSession() {
        extendedSessionService.startSession()
    }
    
    func stopExtendedSession() {
        extendedSessionService.stopSession()
    }
    
    // MARK: - Notification functions
    func checkPermissions() {
        Task {
            await notificationService.checkPermissions()
        }
    }
    
    func notifyUserToResume() {
        guard pomodoroTimer.isWorkSession else { return }
        
        notificationService.notifyUserToResume()
    }
    
    func notifyUserWhenBreakOver() {
        guard !pomodoroTimer.isWorkSession else { return }
        
        let remainingTime = Double(pomodoroTimer.remainingTime)
        guard remainingTime > 0 else { return }

        notificationService.notifyUserWhenBreakOver(timeTilEnd: remainingTime)
    }
    
    func cancelBreakOverNotification() {
        notificationService.cancelNotification(withIdentifier: "breakOverNotification")
    }
    
    // MARK: - Private functions
    private func updateTimeAndProgress() {
        let remainingTimeInMinutes: Int = pomodoroTimer.remainingTime / 60
        let remainingTimeInSeconds: Int = pomodoroTimer.remainingTime % 60
        
        cachedFormattedRemainingTime = String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
        cachedProgress = CGFloat(pomodoroTimer.remainingTime) / CGFloat(pomodoroTimer.currentSession.duration)
    }
}
