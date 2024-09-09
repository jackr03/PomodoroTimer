//
//  PomodoroTimer.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

@Observable class PomodoroTimer {
    private let workDuration: Int
    private let breakDuration: Int
    
    private var remainingTime: Int
    private var isActive: Bool = false
    private var isWorkSession: Bool = true
    var timerFinished: Bool = false
    private var timer: Timer?
        
    init(workDuration: Int, breakDuration: Int) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.remainingTime = workDuration
    }
    
    var currentRemainingTime: Int {
        return remainingTime
    }
    
    var currentIsActive: Bool {
        return isActive
    }
    
    var currentIsWorkSession: Bool {
        return isWorkSession
    }
    
    func startTimer() {
        if isActive { 
            return
        }
        
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func stopTimer() {
        isActive = false
        
        guard let timer = timer else {
            return
        }
        
        timer.invalidate()
        self.timer = nil
    }
    
    func pauseTimer() {

    }
    
    func resetTimer() {
    }
    
    private func countdown() {
        print(remainingTime)
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            isWorkSession.toggle()
            timerFinished = true
            remainingTime = isWorkSession ? workDuration : breakDuration
        }
    }

    
}
