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
        let remainingTimeMinutes: Int = pomodoroTimer.currentRemainingTime / 60
        let remainingTimeSeconds: Int = pomodoroTimer.currentRemainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeMinutes, remainingTimeSeconds)
    }
    
    var isActive: Bool {
        return pomodoroTimer.isActiveStatus
    }
    
    var isTimerFinished: Bool {
        return pomodoroTimer.isTimerFinishedStatus
    }
    
    var currentSession: String {
        return pomodoroTimer.isWorkSessionStatus ? "Work" : "Break"
    }
    
    func startTimer() {
        pomodoroTimer.startTimer()
    }
    
    func stopTimer() {
        pomodoroTimer.stopTimer()
    }
    
    func pauseTimer() {
        pomodoroTimer.pauseTimer()
    }
}
