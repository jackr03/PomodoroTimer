//
//  MockPomodoroTimer.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 06/12/2024.
//

import Foundation
@testable import PomodoroTimer

final class MockPomodoroTimer: PomodoroTimerProtocol {
    
    // MARK: - Stored properties
    let maxSessions: Int = 4

    var currentSession: SessionType
    var currentSessionNumber: Int
    var startingDuration: Int
    var remainingTime: Int
    
    var isTimerActive = false
    var isSessionFinished = false
    
    // MARK: - Inits
    init(
        currentSession: SessionType = .work,
        currentSessionNumber: Int = 0
    ) {
        self.currentSession = currentSession
        self.currentSessionNumber = currentSessionNumber
        self.startingDuration = currentSession.duration
        self.remainingTime = currentSession.duration
    }
    
    // MARK: - Functions
    func startSession() {
        isTimerActive = true
    }
    
    func pauseSession() {
        isTimerActive = false
    }
    
    // MARK: - No-op functions
    func resetSession() {
        
    }
    
    func advanceToNextSession() {
        
    }
    
    func reset() {
        
    }
    
    func deductTime(by seconds: Int) -> Int {
        return 0
    }
}
