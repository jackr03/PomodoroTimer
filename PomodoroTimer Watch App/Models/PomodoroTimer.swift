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
    
    func deductTime(by seconds: Int) {
        remainingTime -= seconds
        
        if remainingTime < 0 {
            remainingTime = 0
        }
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
    
    // MARK: - Private functions
    private func countdown() {
        if remainingTime > 0 {
            deductTime(by: 1)
        } else {
            isTimerFinished = true
        }
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
