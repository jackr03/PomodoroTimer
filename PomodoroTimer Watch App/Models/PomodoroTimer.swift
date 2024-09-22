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
            return UserDefaults.standard.integer(forKey: "workDuration") == 0 ? 1500 : UserDefaults.standard.integer(forKey: "workDuration")
        case .shortBreak:
            return UserDefaults.standard.integer(forKey: "shortBreakDuration") == 0 ? 300 : UserDefaults.standard.integer(forKey: "shortBreakDuration")
        case .longBreak:
            return UserDefaults.standard.integer(forKey: "longBreakDuration") == 0 ? 1800 : UserDefaults.standard.integer(forKey: "workDuration") * 60
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

/**
 Singleton as only timer should exist anyway, and states can be coordinated easier.
 */
@Observable
class PomodoroTimer {
    static let shared = PomodoroTimer()
    
    let maxSessions: Int = 4

    private(set) var remainingTime: Int = SessionType.work.duration
    private(set) var isTimerTicking: Bool = false
    private(set) var session: SessionType = .work
    private(set) var sessionNumber: Int = 0
    
    private var timer: Timer?

    public var isTimerFinished: Bool = false
    
    // Private initialiser to prevent external instantiation
    private init() {}
                    
    var isWorkSession: Bool {
        return session.isWorkSession
    }
    
    func startTimer() {
        isTimerTicking = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func pauseTimer() {
        stopTimerObject()
    }
    
    func resetTimer() {
        remainingTime = session.duration
    }
    
    func endCycle() {
        session = .work
        sessionNumber = 0
        remainingTime = session.duration
        stopTimerObject()
    }
    
    private func stopTimerObject() {
        isTimerTicking = false
        
        guard let timer = timer else { return }
        
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
