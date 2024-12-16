//
//  PomodoroTimerTests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 06/12/2024.
//

import Testing
@testable import PomodoroTimer

final class PomodoroTimerTests {

    var sut: PomodoroTimer!
    
    init() {}
    
    deinit {
        sut = nil
    }
    
    @Test
    func startSession_startsTimerCorrectly() {
        sut = PomodoroTimer()
        sut.startSession()
        #expect(sut.isTimerActive, "Should start timer when called")
    }
    
    @Test
    func pauseSession_stopsTimerCorrectly() {
        sut = PomodoroTimer()
        sut.startSession()
        sut.pauseSession()
        #expect(!sut.isTimerActive, "Should pause timer when called")
    }
    
    @Test(arguments: [
        (PomodoroTimer(currentSession: .work, currentSessionNumber: 0), SessionType.shortBreak, 1, SessionType.shortBreak.duration),
        (PomodoroTimer(currentSession: .work, currentSessionNumber: 3), SessionType.longBreak, 4, SessionType.longBreak.duration),
        (PomodoroTimer(currentSession: .shortBreak, currentSessionNumber: 1), SessionType.work, 1, SessionType.work.duration),
        (PomodoroTimer(currentSession: .longBreak, currentSessionNumber: 4), SessionType.work, 0, SessionType.work.duration),
    ])
    func advanceToNextSession_transitionsCorrectly(sut: PomodoroTimer,
                              expectedCurrentSession: SessionType,
                              expectedCurrentSessionNumber: Int,
                              expectedRemainingTime: Int
                             ) {
        sut.advanceToNextSession()
        #expect(sut.currentSession == expectedCurrentSession, "Should transition to expected session type")
        #expect(sut.currentSessionNumber == expectedCurrentSessionNumber, "Should transition to correct session number")
        #expect(sut.remainingTime == expectedRemainingTime, "Should reset time correctly")
    }
}
