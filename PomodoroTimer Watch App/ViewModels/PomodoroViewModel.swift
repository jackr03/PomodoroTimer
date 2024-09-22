//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation

final class PomodoroViewModel {
    static let shared = PomodoroViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    private let extendedSessionService = ExtendedSessionService.shared
    
    private init() {}
    
    var formattedRemainingTime: String {
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
        return pomodoroTimer.session.displayName
    }
    
    var currentSessionsDone: Int {
        return pomodoroTimer.sessionNumber
    }
    
    var isWorkSession: Bool {
        return pomodoroTimer.isWorkSession
    }
    
    func startTimer() {
        extendedSessionService.startSession()
        pomodoroTimer.startTimer()
    }
        
    func pauseTimer() {
        extendedSessionService.stopSession()
        pomodoroTimer.pauseTimer()
    }
    
    func endCycle() {
        extendedSessionService.stopSession()
        pomodoroTimer.endCycle()
    }

    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    func skipSession() {
        extendedSessionService.stopSession()
        pomodoroTimer.nextSession()
    }
    
    func endSession() {
        extendedSessionService.stopSession()
    }
}
