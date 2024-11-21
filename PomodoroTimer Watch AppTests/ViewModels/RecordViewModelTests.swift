//
//  RecordViewModelTests.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 21/11/2024.
//

import XCTest
@testable import PomodoroTimer

final class RecordViewModelTests: XCTestCase {
    
    var sut: RecordViewModel!
    var mockRecordRepository: MockRecordRepository!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        let record = Record()
        mockRecordRepository = MockRecordRepository(mockRecords: [record])
        sut = RecordViewModel(record: record, repository: mockRecordRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRecordRepository = nil
        
        super.tearDown()
    }
 
    func testDeleteRecord_deletesRecordCorrectly() {
        sut.deleteRecord()
        
        XCTAssertEqual(0, mockRecordRepository.mockRecords.count)
    }
    
}
