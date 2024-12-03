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
    var timer: PomodoroTimer!
    var mockRecordRepository: MockRecordRepository!
    
    init() async {
        timer = PomodoroTimer()
        mockRecordRepository = MockRecordRepository(mockRecords: [])
        sut = await PomodoroViewModel(timer: timer, repository: mockRecordRepository)
    }
    
    deinit {
        sut = nil
        timer = nil
        mockRecordRepository = nil
    }
    
    @Test
    func incrementSessionsCompleted_whenRecordExists_updatesExistingRecord() {
        let existingRecord = Record(date: Date.now,
                                    sessionsCompleted: 5,
                                    dailyTarget: 8)
        mockRecordRepository.createRecord(existingRecord)
        sut.incrementSessionsCompleted()
        
        let recordToday = mockRecordRepository.readRecord(byDate: Date.now)
        
        #expect(recordToday?.sessionsCompleted == 6, "Should update existing record to 6 sessions complete")
    }
    
    @Test
    func incrementSessionsCompleted_whenRecordDoesNotExist_createsNewRecord() {
        sut.incrementSessionsCompleted()
        
        let recordToday = mockRecordRepository.readRecord(byDate: Date.now)!
        
        #expect(mockRecordRepository.mockRecords.count == 1, "Should store the new record")
        #expect(recordToday.sessionsCompleted == 1, "New record should have 1 session complete")
    }
}
