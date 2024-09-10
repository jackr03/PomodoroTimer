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
    let maxSessions: Int = 4
    private var session: SessionType = .work
    private var sessionsDone: Int = 3

    private var timer: Timer?
    private var remainingTime: Int = SessionType.work.duration
    private var isActive: Bool = false
    private var isTimerFinished: Bool = false
    
    var currentRemainingTime: Int {
        return remainingTime
    }
    
    var currentSession: SessionType {
        return session
    }
    
    var currentSessionsDone: Int {
        return sessionsDone
    }
    
    var isActiveStatus: Bool {
        return isActive
    }
        
    var isWorkSessionStatus: Bool {
        return session.isWorkSession
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
        remainingTime = self.session.duration
        
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
            isTimerFinished = true
            self.stopTimer()
            self.nextSession()
        }
    }
    
    private func nextSession() {
        if session.isWorkSession {
            sessionsDone += 1
        }
        
        if session.isWorkSession && sessionsDone == maxSessions {
            session = .longBreak
        } else if session.isWorkSession && sessionsDone != maxSessions {
            session = .shortBreak
        } else {
            session = .work
            if sessionsDone == maxSessions {
                sessionsDone = 0
            }
        }
        
        remainingTime = session.duration
    }
}
