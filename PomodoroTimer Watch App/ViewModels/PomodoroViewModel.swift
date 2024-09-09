//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

final class PomodoroViewModel {
    private var pomodoroTimer: PomodoroTimer
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
    }
    
    var formattedRemainingTime: String {
        let remainingTimeMinutes: Int = pomodoroTimer.remainingTime / 60
        let remainingTimeSeconds: Int = pomodoroTimer.remainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeMinutes, remainingTimeSeconds)
    }
    
    var isTimerFinished: Bool {
        pomodoroTimer.isTimerFinished
    }
    
    var currentSession: String {
        return pomodoroTimer.isWorkSession ? "Work" : "Break"
    }
    
    func startTimer() {
        pomodoroTimer.startTimer()
    }
    
    func pauseTimer() {
    }
    
    func resetTimer() {
    }
    
    func stopTimer() {
        pomodoroTimer.stopTimer()
    }
}
