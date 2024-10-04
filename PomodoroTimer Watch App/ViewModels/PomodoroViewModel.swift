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
    private let extendedSessionService = ExtendedSessionService.shared
    private let notificationService = NotificationService.shared
    
    private(set) var formattedRemainingTime: String = ""
    private(set) var progress: CGFloat = 1.0
    
    private var updateTimer: Timer?
    private var hapticTimer: Timer?
    
    // MARK: - Init
    private init() {
        updateTimeAndProgress()
    }
    
    // MARK: - Computed properties
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
    }
        
    func pauseTimer() {
        pomodoroTimer.pauseTimer()
    }
    
    func endCycle() {
        pomodoroTimer.endCycle()
    }

    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    func skipSession() {
        pomodoroTimer.skipSession()
    }
    
    func startUpdatingTimeAndProgress(withInterval interval: Double) {
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { _ in
            self.updateTimeAndProgress()
        }
    }
    
    // Returns remaining duration
    func deductBreakTime(by seconds: Int) -> Int {
        guard !pomodoroTimer.isWorkSession else { return -1 }
        
        pomodoroTimer.deductTime(by: seconds)
        
        return pomodoroTimer.remainingTime
    }
    
    func refreshDailySessions() {
        if let lastDailyReset = Defaults.getObjectFrom("lastDailyReset") as? Date {
            if !Calendar.current.isDateInToday(lastDailyReset) {
                Defaults.set("lastDailyReset", to: Date.now)
                Defaults.set("sessionsCompletedToday", to: 0)
            }
        } else {
            Defaults.set("lastDailyReset", to: Date.now)
        }
    }
    
    func startTimerIfAutoContinueEnabled() {
        if Defaults.getBoolFrom("autoContinue") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startTimer()
            }
        }
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
        
        formattedRemainingTime = String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
        progress = CGFloat(pomodoroTimer.remainingTime) / CGFloat(pomodoroTimer.currentSession.duration)
    }
}
