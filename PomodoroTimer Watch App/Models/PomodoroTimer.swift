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
    
    private var _remainingTime: Int
    private var _isActive: Bool = false
    private var _isWorkSession: Bool = true
    private var _isTimerFinished: Bool = false
    
    private var timer: Timer?
        
    init(workDuration: Int, breakDuration: Int) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self._remainingTime = workDuration
    }
    
    var remainingTime: Int {
        get {
            return _remainingTime
        } set {
            _remainingTime = newValue
        }
    }
    
    var isActive: Bool {
        get {
            return _isActive
        } set {
            _isActive = newValue
        }
    }
        
    var isWorkSession: Bool {
        get {
            return _isWorkSession
        } set {
            _isWorkSession = newValue
        }
    }
    
    var isTimerFinished: Bool {
        get {
            return _isTimerFinished
        } set {
            _isTimerFinished = newValue
        }
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
            isTimerFinished = true
            remainingTime = isWorkSession ? workDuration : breakDuration
        }
    }

    
}
