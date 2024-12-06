//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import Observation

// TODO: Maybe move this out of the file
/**
 Represents the possible types of sessions in a Pomodoro cycle.
 
 - work: A work session.
 - shortBreak: A short break after completing a work session.
 - longBreak: A longer break after completing a series of work sessions.
 */
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

protocol PomodoroTimerProtocol {
    var maxSessions: Int { get }
    var currentSession: SessionType { get }
    var currentSessionNumber: Int { get}
    var remainingTime: Int { get }
    var hasSessionStarted: Bool { get }
    var isSessionFinished: Bool { get }
    var isTimerActive: Bool { get }
    
    func startSession()
    func pauseSession()
    func resetSession()
    func advanceToNextSession()
    func reset()
    func deductTime(by seconds: Int) -> Int
}

@Observable
class PomodoroTimer: PomodoroTimerProtocol {
    
    // MARK: - Stored properties
    let maxSessions = 4
    
    private(set) var currentSession: SessionType
    private(set) var currentSessionNumber: Int
    private(set) var remainingTime: Int
    private(set) var hasSessionStarted = false
    private(set) var isSessionFinished = false
    
    private var timer: Timer?
    
    // MARK: - Init
    init(
        currentSession: SessionType = .work,
        currentSessionNumber: Int = 0
    ) {
        self.currentSession = currentSession
        self.currentSessionNumber = currentSessionNumber
        self.remainingTime = currentSession.duration
    }
    
    // MARK: - Computed properties
    var isTimerActive: Bool { timer != nil }
    
    // MARK: - Functions
    func startSession() {
        guard timer == nil else { return }
                
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.countdown()
        }
    }
    
    func pauseSession() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func resetSession() {
        remainingTime = currentSession.duration
    }
    
    /**
     Advances to the next session by pausing the current session before transitioning to the appropriate session
     based on the current session type and resetting the time.
     
     - If coming from a work session, increment the number of sessions done before transitioning to either a short break
     or long break, depending on how many session have been completed so far.
     - If coming from a short break, transition to a work session.
     - If coming from a long break, reset the session count before transitioning to a work session.
     */
    func advanceToNextSession() {
        hasSessionStarted = false
        isSessionFinished = false
        
        switch(currentSession) {
        case .work:
            currentSessionNumber += 1
            currentSession = currentSessionNumber == maxSessions ? .longBreak : .shortBreak
        case .shortBreak:
            currentSession = .work
        case .longBreak:
            currentSessionNumber = 0
            currentSession = .work
        }

        resetSession()
    }
    
    func reset() {
        currentSession = .work
        currentSessionNumber = 0
        remainingTime = currentSession.duration
        hasSessionStarted = false
        isSessionFinished = false
        
        pauseSession()
    }
    
    func deductTime(by seconds: Int) -> Int {
        remainingTime -= seconds
        return remainingTime
    }
    
    // MARK: - Private functions
    private func countdown() {
        if remainingTime > 0 {
            remainingTime -= 1
            hasSessionStarted = true
        } else {
            pauseSession()
            isSessionFinished = true
        }
    }
}
