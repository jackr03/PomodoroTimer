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
    var mockRecordRepository: MockRecordRepository!
    
    init() async {
        let record = Record()
        mockRecordRepository = MockRecordRepository(mockRecords: [record])
        sut = await RecordViewModel(record: record, repository: mockRecordRepository)
    }
    
    deinit {
        sut = nil
        mockRecordRepository = nil
    }
 
    @Test
    func deleteRecord_deletesRecordCorrectly() {
        sut.deleteRecord()
        #expect(mockRecordRepository.mockRecords.count == 0)
    }
}
