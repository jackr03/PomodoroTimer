//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation

final class PomodoroViewModel {
    private var pomodoroTimer: PomodoroTimer
    private var extendedSessionService: ExtendedSessionService
    
    init(_ pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
        self.extendedSessionService = ExtendedSessionService()
    }
    
    var formattedRemainingTime: String {
        let remainingTimeMinutes: Int = pomodoroTimer.currentRemainingTime / 60
        let remainingTimeSeconds: Int = pomodoroTimer.currentRemainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeMinutes, remainingTimeSeconds)
    }
    
    var isTimerTicking: Bool {
        return pomodoroTimer.isTimerTickingStatus
    }
    
    var isTimerFinished: Bool {
        return pomodoroTimer.isTimerFinishedStatus
    }
    
    var maxSessions: Int {
        return pomodoroTimer.maxSessions
    }
    
    var currentSession: String {
        return pomodoroTimer.currentSession.displayName
    }
    
    var currentSessionsDone: Int {
        return pomodoroTimer.currentsessionNumber
    }
    
    var isWorkSession: Bool {
        return pomodoroTimer.isWorkSessionStatus
    }
    
    func startTimer() {
        extendedSessionService.startSession()
        pomodoroTimer.startTimer()
    }
        
    func pauseTimer() {
        extendedSessionService.stopSession()
        pomodoroTimer.pauseTimer()
    }
    
    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    func endCycle() {
        extendedSessionService.stopSession()
        pomodoroTimer.endCycle()
    }
    
    /**
     End session and trigger haptics.
     */
    func endSession() {
        extendedSessionService.stopSession()
        extendedSessionService.startHaptics()
    }
    
    /**
     Stop the haptic alarm and reset isTimerFinished.
     */
    func stopHaptics() {
        extendedSessionService.stopHaptics()
        pomodoroTimer.isTimerFinishedStatus = false
    }
}
