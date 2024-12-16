//
//  RecordViewModelTests.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 21/11/2024.
//

import Testing
@testable import PomodoroTimer

final class RecordViewModelTests {
    
    var sut: RecordViewModel!
    var record: Record!
    var mockRecordRepository: MockRecordRepository!
    
    init() {}
    
    deinit {
        sut = nil
        record = nil
        mockRecordRepository = nil
    }
    
    private func setUp(_ record: Record = Record()) async {
        mockRecordRepository = MockRecordRepository(mockRecords: [record])
        sut = await RecordViewModel(record: record, repository: mockRecordRepository)
    }

    @Test(arguments: [
        (Record(sessionsCompleted: 0, dailyTarget: 8), "Let's get to work!"),
        (Record(sessionsCompleted: 4, dailyTarget: 8), "Keep it up!"),
        (Record(sessionsCompleted: 8, dailyTarget: 8), "Well done!"),
        (Record(sessionsCompleted: 9, dailyTarget: 8), "Well done!"),
    ])
    func statusMessage_returnsCorrectMessageDependingOnSessionsCompleted(
        record: Record,
        expectedStatusMessage: String
    ) async {
        await setUp(record)
        #expect(sut.statusMessage == expectedStatusMessage, "Should return correct status message")
    }
 
    @Test
    func deleteRecord_deletesRecordCorrectly() async {
        await setUp()
        
        sut.deleteRecord()
        #expect(mockRecordRepository.mockRecords.count == 0)
    }
}
