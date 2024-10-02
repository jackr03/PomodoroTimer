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
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Computed properties
    var formattedRemainingMinutes: String {
        let remainingTimeInMinutes: Int = pomodoroTimer.remainingTime / 60
        
        return String(format: "%02d:--", remainingTimeInMinutes)
    }
    
    var formattedRemainingMinutesAndSeconds: String {
        let remainingTimeInMinutes: Int = pomodoroTimer.remainingTime / 60
        let remainingTimeInSeconds: Int = pomodoroTimer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeInMinutes, remainingTimeInSeconds)
    }
    
    var isTimerTicking: Bool {
        return pomodoroTimer.isTimerTicking
    }
    
    var maxSessions: Int {
        return pomodoroTimer.maxSessions
    }
    
    var currentSession: String {
        return pomodoroTimer.currentSession.rawValue
    }
    
    var currentSessionsDone: Int {
        return pomodoroTimer.currentSessionNumber
    }
    
    var isWorkSession: Bool {
        return pomodoroTimer.isWorkSession
    }
    
    var showingFinishedAlert: Bool {
        get { return pomodoroTimer.isTimerFinished }
        set { pomodoroTimer.isTimerFinished = newValue }
    }
    
    var isExtendedSessionRunning: Bool {
        return extendedSessionService.isRunning
    }
    
    // Return true if not yet set so that the red triangle doesn't show up until the user tries to start a timer
    var permissionsGranted: Bool {
        return notificationService.permissionsGranted ?? true
    }
    
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
    
    func deductBreakTime(by seconds: Int) {
        guard !pomodoroTimer.isWorkSession else { return }
        pomodoroTimer.deductTime(by: seconds)
        
        // This method is called on the timer during break sessions only
        // Therefore we can skip to next session directly to avoid showing alert when user reopens app
        if pomodoroTimer.remainingTime <= 0 {
            startTimerIfAutoContinueEnabled()
        }
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
    
    // MARK: - Extended session functions
    func startExtendedSession() {
        extendedSessionService.startSession()
    }
    
    func stopExtendedSession() {
        extendedSessionService.stopSession()
    }
    
    func playHaptics() {
        extendedSessionService.playHaptics()
    }
    
    func stopHaptics() {
        extendedSessionService.stopHaptics()
        startTimerIfAutoContinueEnabled()
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
    private func startTimerIfAutoContinueEnabled() {
        if Defaults.getBoolFrom("autoContinue") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startTimer()
            }
        }
    }
}
