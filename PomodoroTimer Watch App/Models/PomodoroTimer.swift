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
    
    private let totalSessionsCompletedKey = "totalSessionsCompleted"
    private let sessionsCompletedTodayKey = "sessionsCompletedToday"
    
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

        // TODO: Convert this to use the Setting Enum
        var duration: Int {
            let storedValue = Defaults.getIntFrom(settingKey)
            return storedValue == 0 ? defaultSetting : storedValue
        }
    
        var settingKey: String {
            switch self {
            case .work:
                return "workDuration"
            case .shortBreak:
                return "shortBreakDuration"
            case .longBreak:
                return "longBreakDuration"
            }
        }
        
        var defaultSetting: Int {
            switch self {
            case .work:
                return 1500
            case .shortBreak:
                return 300
            case .longBreak:
                return 1800
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
            remainingTime -= 1
        } else {
            isTimerFinished = true
            self.nextSession()
        }
    }
    
    private func incrementSessionsCompleted() {
        var currentTotalSessionsCompleted = Defaults.getIntFrom(totalSessionsCompletedKey)
        var currentSessionsCompletedToday = Defaults.getIntFrom(sessionsCompletedTodayKey)
        
        Defaults.set(totalSessionsCompletedKey, to: currentTotalSessionsCompleted += 1)
        Defaults.set(sessionsCompletedTodayKey, to: currentSessionsCompletedToday += 1)
    }
}
