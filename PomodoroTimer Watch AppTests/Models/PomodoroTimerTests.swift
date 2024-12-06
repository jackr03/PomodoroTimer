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
    
    @Test
    func advanceToNextSession_fromWorkSession_transitionsToShortBreakWhenSessionsCompleteLessThanMax() {
        sut = PomodoroTimer(currentSession: .work, currentSessionNumber: 0)
        sut.advanceToNextSession()
        #expect(sut.currentSession == .shortBreak, "Should transition to a short break")
        #expect(sut.remainingTime == SessionType.shortBreak.duration, "Should reset time to shortBreak duration")
        #expect(sut.currentSessionNumber == 1, "Should increment current session number")
    }
    
    @Test
    func advanceToNextSession_fromWorkSession_transitionsToLongBreakWhenSessionsCompleteIsMax() {
        sut = PomodoroTimer(currentSession: .work, currentSessionNumber: 3)
        sut.advanceToNextSession()
        #expect(sut.currentSession == .longBreak, "Should transition to a long break")
        #expect(sut.remainingTime == SessionType.longBreak.duration, "Should reset time to longBreak duration")
        #expect(sut.currentSessionNumber == 4, "Should increment current session number")
    }
    
    @Test
    func advanceToNextSession_fromShortBreak_transitionsToWorkSession() {
        sut = PomodoroTimer(currentSession: .shortBreak, currentSessionNumber: 1)
        sut.advanceToNextSession()
        #expect(sut.currentSession == .work, "Should transition to a work session")
        #expect(sut.remainingTime == SessionType.work.duration, "Should reset time to work duration")
        #expect(sut.currentSessionNumber == 1, "Should not increment current session number")
    }
    
    @Test
    func advanceToNextSession_fromLongBreak_transitionsToWorkSessionAndResetsSessionCount() {
        sut = PomodoroTimer(currentSession: .longBreak, currentSessionNumber: 4)
        sut.advanceToNextSession()
        #expect(sut.currentSession == .work, "Should transition to a work session")
        #expect(sut.remainingTime == SessionType.work.duration, "Should reset time to work duration")
        #expect(sut.currentSessionNumber == 0, "Should reset session count")
    }
}
