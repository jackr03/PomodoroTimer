//
//  PomodoroTimer.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

enum SessionType: String {
    case work = "Work"
    case shortBreak = "Break"
    case longBreak = "Long Break"
    
    var displayName: String {
        return self.rawValue
    }

    var duration: Int {
        switch self {
        case .work:
            return 1
        case .shortBreak:
            return 2
        case .longBreak:
            return 3
        }
    }
    
    var isWorkSession: Bool {
        switch self {
        case .work:
            return true
        case .shortBreak:
            return false
        case .longBreak:
            return false
        }
    }
}

@Observable
class PomodoroTimer {
    private var timer: Timer?
    private var remainingTime: Int = SessionType.work.duration
    private var isTimerTicking: Bool = false
    private var isTimerFinished: Bool = false
    
    let maxSessions: Int = 4
    private var session: SessionType = .work
    private var sessionNumber: Int = 3
    
    var currentRemainingTime: Int {
        return remainingTime
    }
    
    var currentSession: SessionType {
        return session
    }
    
    var currentsessionNumber: Int {
        return sessionNumber
    }
    
    var isTimerTickingStatus: Bool {
        return isTimerTicking
    }
    
    var isTimerFinishedStatus: Bool {
        get {
            return isTimerFinished
        } set {
            isTimerFinished = newValue
        }
    }
        
    var isWorkSessionStatus: Bool {
        return session.isWorkSession
    }
    
    func startTimer() {
        isTimerTicking = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func stopTimer() {
        session = .work
        sessionNumber = 0
        remainingTime = session.duration
        stopTimerObject()
    }
    
    func pauseTimer() {
        stopTimerObject()
    }
    
    func resetTimer() {
        remainingTime = session.duration
    }
    
    private func stopTimerObject() {
        isTimerTicking = false
        
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
            isTimerFinished = true
            self.nextSession()
        }
    }
    
    private func nextSession() {
        stopTimerObject()
        
        if session.isWorkSession {
            sessionNumber += 1
            
            if sessionNumber == maxSessions {
                session = .longBreak
            } else {
                session = .shortBreak
            }
        } else {
            session = .work
            
            if sessionNumber == maxSessions {
                sessionNumber = 0
            }
        }
        
        remainingTime = session.duration
    }
}
