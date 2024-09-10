//
//  PomodoroTimer.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

@Observable
class PomodoroTimer {
    let workDuration: Int
    let breakDuration: Int
    
    private var remainingTime: Int
    private var isActive: Bool = false
    private var isWorkSession: Bool = true
    private var isTimerFinished: Bool = false
    
    private var timer: Timer?
        
    init(workDuration: Int, breakDuration: Int) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.remainingTime = workDuration
    }
    
    var currentRemainingTime: Int {
        return remainingTime
    }
    
    var isActiveStatus: Bool {
        return isActive
    }
        
    var isWorkSessionStatus: Bool {
        return isWorkSession
    }
    
    var isTimerFinishedStatus: Bool {
        return isTimerFinished
    }
    
    func startTimer() {
        isActive = true
        isTimerFinished = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func stopTimer() {
        isActive = false
        remainingTime = isWorkSession ? workDuration : breakDuration
        
        guard let timer = timer else {
            return
        }
        
        timer.invalidate()
        self.timer = nil
    }
    
    func pauseTimer() {
        isActive = false
        
        guard let timer = timer else {
            return
        }
        
        timer.invalidate()
        self.timer = nil
    }
    
    private func countdown() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            self.stopTimer()
            isTimerFinished = true
            isWorkSession.toggle()
            remainingTime = isWorkSession ? workDuration : breakDuration
        }
    }
}
