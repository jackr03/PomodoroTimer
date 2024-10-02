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
    // MARK: - Properties
    static let shared = PomodoroTimer()
    
    public let maxSessions: Int = 4

    private(set) var remainingTime: Int = SessionType.work.duration
    private(set) var isTimerTicking: Bool = false
    private(set) var currentSession: SessionType = .work
    private(set) var currentSessionNumber: Int = 0
    private(set) var sessionHasStarted: Bool = false
    
    private var timer: Timer?

    public var isTimerFinished: Bool = false
    
    // MARK: - Init
    private init() {}
    
    // MARK: - SessionType Enum
    enum SessionType: String {
        case work = "WORK"
        case shortBreak = "BREAK"
        case longBreak = "LONG BREAK"

        var duration: Int {
            switch self {
            case .work: return NumericSetting.workDuration.currentValue
            case .shortBreak: return NumericSetting.shortBreakDuration.currentValue
            case .longBreak: return NumericSetting.longBreakDuration.currentValue
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
    
    // MARK: - Computed properties
    var isWorkSession: Bool {
        return currentSession.isWorkSession
    }
    
    // MARK: - Timer functions
    func startTimer() {
        isTimerTicking = true
        sessionHasStarted = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func pauseTimer() {
        isTimerTicking = false
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func resetTimer() {
        remainingTime = currentSession.duration
    }
    
    func deductTime(by seconds: Int) {
        remainingTime -= seconds
    }
    
    func skipSession() {
        nextSession(skipped: true)
    }
    
    func endCycle() {
        currentSession = .work
        currentSessionNumber = 0
        remainingTime = currentSession.duration
        sessionHasStarted = false
        pauseTimer()
    }
    
    // MARK: - Private functions
    private func countdown() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            isTimerFinished = true
            nextSession()
        }
    }
    
    private func nextSession(skipped: Bool = false) {
        pauseTimer()
        
        if currentSession.isWorkSession {
            currentSessionNumber += 1
            
            if !skipped {
                incrementSessionsCompleted()
            }
            
            if currentSessionNumber == maxSessions {
                currentSession = .longBreak
            } else {
                currentSession = .shortBreak
            }
        } else {
            if currentSessionNumber == maxSessions {
                currentSessionNumber = 0
            }
            
            currentSession = .work
        }
        
        remainingTime = currentSession.duration
        sessionHasStarted = false
    }
    
    private func incrementSessionsCompleted() {
        let totalSessionsCompletedKey = "totalSessionsCompleted"
        let sessionsCompletedTodayKey = "sessionsCompletedToday"
        
        let currentTotalSessionsCompleted = Defaults.getIntFrom(totalSessionsCompletedKey) + 1
        let currentSessionsCompletedToday = Defaults.getIntFrom(sessionsCompletedTodayKey) + 1
        
        Defaults.set(totalSessionsCompletedKey, to: currentTotalSessionsCompleted)
        Defaults.set(sessionsCompletedTodayKey, to: currentSessionsCompletedToday)
    }
}
