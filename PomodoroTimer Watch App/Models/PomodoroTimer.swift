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
    static let shared = PomodoroTimer()
    
    private let totalSessionsCompletedKey = "totalSessionsCompleted"
    private let sessionsCompletedTodayKey = "sessionsCompletedToday"
    
    public let maxSessions: Int = 4

    private(set) var remainingTime: Int = SessionType.work.duration
    private(set) var isTimerTicking: Bool = false
    private(set) var currentSession: SessionType = .work
    private(set) var currentSessionNumber: Int = 0
    
    private var timer: Timer?

    public var isTimerFinished: Bool = false
    
    private init() {}
    
    enum SessionType: String {
        case work = "WORK"
        case shortBreak = "BREAK"
        case longBreak = "LONG BREAK"

        var duration: Int {
            switch self {
            case .work:
                return UserDefaults.standard.integer(forKey: "workDuration") == 0 ? 1500 : UserDefaults.standard.integer(forKey: "workDuration")
            case .shortBreak:
                return UserDefaults.standard.integer(forKey: "shortBreakDuration") == 0 ? 300 : UserDefaults.standard.integer(forKey: "shortBreakDuration")
            case .longBreak:
                return UserDefaults.standard.integer(forKey: "longBreakDuration") == 0 ? 1800 : UserDefaults.standard.integer(forKey: "longBreakDuration")
            }
        }
        
        var isWorkSession: Bool {
            switch self {
            case .work:
                return true
            case .shortBreak, .longBreak:
                return false
            }
        }
    }
                    
    var isWorkSession: Bool {
        return currentSession.isWorkSession
    }
    
    func startTimer() {
        isTimerTicking = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func pauseTimer() {
        isTimerTicking = false
        
        guard let timer = timer else { return }
        
        timer.invalidate()
        self.timer = nil
    }
    
    func resetTimer() {
        remainingTime = currentSession.duration
    }
    
    func nextSession() {
        pauseTimer()
        
        if currentSession.isWorkSession {
            currentSessionNumber += 1
            incrementSessionsCompleted()
            
            if currentSessionNumber == maxSessions {
                currentSession = .longBreak
            } else {
                currentSession = .shortBreak
            }
        } else {
            currentSession = .work
            
            if currentSessionNumber == maxSessions {
                currentSessionNumber = 0
            }
        }
        
        remainingTime = currentSession.duration
    }
    
    func endCycle() {
        currentSession = .work
        currentSessionNumber = 0
        remainingTime = currentSession.duration
        pauseTimer()
    }
        
    private func countdown() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            isTimerFinished = true
            self.nextSession()
        }
    }
    
    /**
     UserDefaults returns 0 if key doesn't exist, so no need to account for that situation
     */
    private func incrementSessionsCompleted() {
        var currentTotalSessionsCompleted = UserDefaults.standard.integer(forKey: totalSessionsCompletedKey)
        var currentSessionsCompletedToday = UserDefaults.standard.integer(forKey: sessionsCompletedTodayKey)
        
        currentTotalSessionsCompleted += 1
        currentSessionsCompletedToday += 1
        
        UserDefaults.standard.set(currentTotalSessionsCompleted, forKey: totalSessionsCompletedKey)
        UserDefaults.standard.set(currentSessionsCompletedToday, forKey: sessionsCompletedTodayKey)
    }
}
