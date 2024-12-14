//
//  PomodoroViewModelTests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 03/12/2024.
//

import Foundation
import Testing
@testable import PomodoroTimer

final class PomodoroViewModelTests {
    
    var sut: PomodoroViewModel!
    var timer: MockPomodoroTimer!
    var mockRecordRepository: MockRecordRepository!
    
    init() async {
        timer = MockPomodoroTimer()
        mockRecordRepository = MockRecordRepository(mockRecords: [])
        sut = await PomodoroViewModel(timer: timer, repository: mockRecordRepository)
    }
    
    deinit {
        sut = nil
        timer = nil
        mockRecordRepository = nil
    }
    
    @Test
    func formattedRemainingTime_returnsCorrectStringRepresentation() {
        #expect(sut.formattedRemainingTime == "25:00", "Should format remaining time correctly")
    }
    
    @Test
    func incrementSessionsCompleted_whenRecordExists_updatesExistingRecord() {
        let existingRecord = Record(date: Date.now,
                                    sessionsCompleted: 5,
                                    dailyTarget: 8,
                                    timeSpent: 25)
        
        mockRecordRepository.createRecord(existingRecord)
        sut.updateRecord(withTime: 25)
        
        let recordToday = mockRecordRepository.readRecord(byDate: Date.now)!
        
        #expect(recordToday.sessionsCompleted == 6, "Should update existing record to 6 sessions complete")
        #expect(recordToday.timeSpent == 50, "Should update existing record to 50 minutes spent")
    }
    
    @Test
    func incrementSessionsCompleted_whenRecordDoesNotExist_createsNewRecord() {
        sut.updateRecord(withTime: 25)
        
        let recordToday = mockRecordRepository.readRecord(byDate: Date.now)!
        
        #expect(mockRecordRepository.mockRecords.count == 1, "Should store the new record")
        #expect(recordToday.sessionsCompleted == 1, "New record should have 1 session complete")
        #expect(recordToday.timeSpent == 25, "New record should have 25 minutes spent")
    }
}
