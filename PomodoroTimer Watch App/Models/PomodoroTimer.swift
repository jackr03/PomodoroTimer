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
    
    // MARK: - Stored properties
    private(set) var currentSession: SessionType
    private(set) var currentSessionNumber: Int
    private(set) var maxSessions: Int
    private(set) var isSessionInProgress: Bool
    private(set) var remainingTime: Int
    
    private var timer: Timer?

    public var isSessionFinished = false
    
    // MARK: - Init
    init() {
        self.currentSession = .work
        self.currentSessionNumber = 0
        self.maxSessions = 4
        self.isSessionInProgress = false
        self.remainingTime = SessionType.work.duration
    }
    
    // MARK: - SessionType Enum
    enum SessionType: String {
        case work = "WORK"
        case shortBreak = "BREAK"
        case longBreak = "L. BREAK"

        var duration: Int {
            switch self {
            case .work: return SettingsManager.shared.get(.workDuration)
            case .shortBreak: return SettingsManager.shared.get(.shortBreakDuration)
            case .longBreak: return SettingsManager.shared.get(.longBreakDuration)
            }
        }
    }
    
    // MARK: - Computed properties
    var isWorkSession: Bool { currentSession == .work }
    var isTimerTicking: Bool { timer != nil }
    
    // MARK: - Functions
    func startTimer() {
        guard timer == nil else { return }
        
        isSessionInProgress = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func pauseTimer() {
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
        nextSession()
    }
    
    func endCycle() {
        currentSession = .work
        currentSessionNumber = 0
        remainingTime = currentSession.duration
        isSessionInProgress = false
        pauseTimer()
    }
    
    // MARK: - Private functions
    private func countdown() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            isSessionFinished = true
            nextSession()
        }
    }
    
    private func nextSession() {
        pauseTimer()
        
        if isWorkSession {
            currentSessionNumber += 1
            currentSession = currentSessionNumber == maxSessions ? .longBreak : .shortBreak
        } else {
            if currentSessionNumber == maxSessions {
                currentSessionNumber = 0
            }
            
            currentSession = .work
        }
        
        remainingTime = currentSession.duration
        isSessionInProgress = false
    }
}
