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
    
    // MARK: - Functions
    func startTimer() {
        notificationService.requestPermission()
        pomodoroTimer.startTimer()
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
    
    func deductTime(by seconds: Int) {
        pomodoroTimer.deductTime(by: seconds)
    }
    
    func nextSession() {
        pomodoroTimer.nextSession()
    }
    
    // TODO: Make this not increment session done count
    func skipSession() {
        pomodoroTimer.nextSession()
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
        
        if Defaults.getBoolFrom("autoContinue") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startTimer()
            }
        }
    }
    
    func notifyUserToResume() {
        notificationService.notifyUserToResume()
    }
}
