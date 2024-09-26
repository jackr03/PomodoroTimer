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
    
    // MARK: - Functions
    func startTimer() {
        pomodoroTimer.startTimer()
        extendedSessionService.startSession()
    }
        
    func pauseTimer() {
        pomodoroTimer.pauseTimer()
        extendedSessionService.stopSession()
    }
    
    func endCycle() {
        pomodoroTimer.endCycle()
        extendedSessionService.stopSession()
    }

    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    func skipSession() {
        pomodoroTimer.nextSession()
        extendedSessionService.stopSession()
    }
    
    func playHaptics() {
        extendedSessionService.playHaptics()
    }
    
    func stopHaptics() {
        extendedSessionService.stopSession()
        
        if Defaults.getBoolFrom("autoContinue") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startTimer()
            }
        }
    }
    
    func updateDailySessionsIfNeeded() {
        let currentDate = Date.now
        let lastResetDate = Defaults.getObjectFrom("lastResetDate") as? Date ?? Date.now
        
        if !Calendar.current.isDate(currentDate, inSameDayAs: lastResetDate) {
            Defaults.set("lastResetDate", to: currentDate)
            Defaults.set("sessionsCompletedToday", to: 0)
        }
    }
}
