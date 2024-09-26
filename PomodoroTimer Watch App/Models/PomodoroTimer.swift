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
    
    private let defaults = UserDefaults.standard
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
    
    // MARK: - SessionType Enum
    enum SessionType: String {
        case work = "WORK"
        case shortBreak = "BREAK"
        case longBreak = "LONG BREAK"

        var duration: Int {
            let storedValue = UserDefaults.standard.integer(forKey: settingKey)
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
    // TODO: Move ExtendedRuntimeSession stuff to the internal model
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
        var currentTotalSessionsCompleted = defaults.integer(forKey: totalSessionsCompletedKey)
        var currentSessionsCompletedToday = defaults.integer(forKey: sessionsCompletedTodayKey)
        
        currentTotalSessionsCompleted += 1
        currentSessionsCompletedToday += 1
        
        defaults.set(currentTotalSessionsCompleted, forKey: totalSessionsCompletedKey)
        defaults.set(currentSessionsCompletedToday, forKey: sessionsCompletedTodayKey)
    }
}
