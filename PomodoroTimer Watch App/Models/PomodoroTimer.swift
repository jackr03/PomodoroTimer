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
    
    public let maxSessions = 4

    private(set) var remainingTime = SessionType.work.duration
    private(set) var currentSession: SessionType = .work
    private(set) var currentSessionNumber = 0
    private(set) var isTimerTicking = false
    private(set) var isSessionInProgress = false
    
    private var timer: Timer?

    public var isSessionFinished = false
    
    // MARK: - Init
    private init() {}
    
    // MARK: - SessionType Enum
    enum SessionType: String {
        case work = "WORK"
        case shortBreak = "BREAK"
        case longBreak = "L. BREAK"

        var duration: Int {
            switch self {
            case .work: return NumberSetting.workDuration.currentValue
            case .shortBreak: return NumberSetting.shortBreakDuration.currentValue
            case .longBreak: return NumberSetting.longBreakDuration.currentValue
            }
        }
        
        var isWorkSession: Bool { self == .work }
    }
    
    // MARK: - Computed properties
    var isWorkSession: Bool { currentSession.isWorkSession }
    
    // MARK: - Functions
    func startTimer() {
        isTimerTicking = true
        isSessionInProgress = true
        
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
        
        if currentSession.isWorkSession {
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
