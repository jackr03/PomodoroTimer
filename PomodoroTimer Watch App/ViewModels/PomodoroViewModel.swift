//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

final class PomodoroViewModel {
    private var remainingTime: Int = 0
    private var isActive: Bool = false
    private var isWorkSession: Bool = false
    
    private var pomodoroTimer: PomodoroTimer
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
        self.remainingTime = pomodoroTimer.currentRemainingTime
        self.isActive = pomodoroTimer.currentIsActive
        self.isWorkSession = pomodoroTimer.currentIsWorkSession
    }
    
    var formattedRemainingTime: String {
        let remainingTimeMinutes: Int = pomodoroTimer.currentRemainingTime / 60
        let remainingTimeSeconds: Int = pomodoroTimer.currentRemainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeMinutes, remainingTimeSeconds)
    }
    
    var timerFinished: Bool {
        pomodoroTimer.timerFinished
    }
    
    var currentSession: String {
        return isWorkSession ? "Work" : "Break"
    }
    
    func startTimer() {
        pomodoroTimer.startTimer()
        self.isActive = true
    }
    
    func pauseTimer() {
    }
    
    func resetTimer() {
    }
    
    func stopTimer() {
        pomodoroTimer.stopTimer()
        self.isActive = false
    }
}
