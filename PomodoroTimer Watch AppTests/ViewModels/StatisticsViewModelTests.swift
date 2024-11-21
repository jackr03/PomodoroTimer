//
//  StatisticsViewModelTests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 18/11/2024.
//

import XCTest
@testable import PomodoroTimer

final class StatisticsViewModelTests: XCTestCase {

    var sut: StatisticsViewModel!
    var mockRecordRepository: MockRecordRepository!
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        mockRecordRepository = nil
        
        super.tearDown()
    }
        
    func testFetchAllRecords_returnsAllRecords() {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1)),
            Record(date: createDate(year: 2024, month: 1, day: 2))
        ]
        
        setUpWithMockRecords(records)
        
        sut.fetchAllRecords()
        
        XCTAssertEqual(2, sut.records.count)
    }
        
    func testAddNewRecord_addsNewRecord() {
        setUpWithNoRecords()
        
        let recordToday = sut.addNewRecord()
        
        XCTAssertEqual(1, sut.records.count)
        XCTAssertEqual(Calendar.current.startOfToday, recordToday.date)
        XCTAssertEqual(0, recordToday.sessionsCompleted)
    }
        
    func testDeleteAllRecord_deletesAllRecords() {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1)),
            Record(date: createDate(year: 2024, month: 1, day: 2))
        ]

        setUpWithMockRecords(records)
        
        sut.deleteAllRecords()
        
        XCTAssertEqual(0, sut.records.count)
    }
    
    func testNoRecords_returnZeroOrEmptyValues() {
        setUpWithNoRecords()
        
        XCTAssertTrue(sut.recordsThisWeek.isEmpty)
        XCTAssertTrue(sut.recordsThisMonth.isEmpty)
        XCTAssertEqual(0, sut.totalSessions)
        XCTAssertEqual(0, sut.currentStreak)
        XCTAssertEqual(0, sut.longestStreak)
    }
    
    func testRecordToday_returnsCorrectValue() {
        let recordYesterday = Record(date: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, sessionsCompleted: 0, dailyTarget: 8)
        let recordToday = Record(date: Date.now, sessionsCompleted: 0, dailyTarget: 8)
        
        setUpWithMockRecords([recordYesterday, recordToday])
        
        XCTAssertEqual(recordToday, sut.recordToday)
    }
    
    func testRecordToday_createsNewRecordWhenNoRecordToday() {
        setUpWithNoRecords()
        
        let recordToday = sut.recordToday
        
        XCTAssertEqual(Calendar.current.startOfToday, recordToday.date)
        XCTAssertEqual(0, recordToday.sessionsCompleted)
    }
    
    func testRecordsForWeek_returnsCorrectValue() {
        let testDate = createDate(year: 2024, month: 1, day: 5)
        let recordInWeek1 = Record(date: createDate(year: 2024, month: 1, day: 1));
        let recordInWeek2 = Record(date: createDate(year: 2024, month: 1, day: 2));
        let recordNotInWeek = Record(date: createDate(year: 2024, month: 1, day: 31));
        
        setUpWithMockRecords([recordInWeek1, recordInWeek2, recordNotInWeek])
        
        XCTAssertEqual([recordInWeek1, recordInWeek2], sut.recordsForWeek(date: testDate))
    }
    
    func testRecordsForMonth_returnsCorrectValue() {
        let testDate = createDate(year: 2024, month: 1, day: 1)
        let recordInMonth1 = Record(date: createDate(year: 2024, month: 1, day: 1));
        let recordInMonth2 = Record(date: createDate(year: 2024, month: 1, day: 2));
        let recordNotInMonth = Record(date: createDate(year: 2024, month: 2, day: 1));
        
        setUpWithMockRecords([recordInMonth1, recordInMonth2, recordNotInMonth])
        
        XCTAssertEqual([recordInMonth1, recordInMonth2], sut.recordsForMonth(date: testDate))
    }

    func testTotalSessions_returnsCorrectValue() {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 5, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 4, day: 3), sessionsCompleted: 4, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 11, day: 9), sessionsCompleted: 7, dailyTarget: 8)
        ]
        
        setUpWithMockRecords(records)
        
        XCTAssertEqual(16, sut.totalSessions)
    }
    
    func testStreak_returnsCorrectValue() {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 2), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 5), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 6), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 7), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        setUpWithMockRecords(records)
        
        let mockCurrentDate = createDate(year: 2024, month: 1, day: 7)
        
        XCTAssertEqual(3, sut.streak(for: mockCurrentDate))
    }
    
    func testStreak_spansMonthsAndYears() {
        let records = [
            Record(date: createDate(year: 2023, month: 12, day: 31), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        setUpWithMockRecords(records)
        
        let mockCurrentDate = createDate(year: 2024, month: 1, day: 1)

        XCTAssertEqual(2, sut.streak(for: mockCurrentDate))
    }
    
    func testLongestStreak_returnsCorrectValue() {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 2), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 3), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 30), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 31), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        setUpWithMockRecords(records)
        
        XCTAssertEqual(3, sut.longestStreak)
    }

}

// MARK: - Helper methods
extension StatisticsViewModelTests {
    
    func setUpWithNoRecords() {
        mockRecordRepository = MockRecordRepository(mockRecords: [])
        sut = StatisticsViewModel(repository: mockRecordRepository)
    }
    
    func setUpWithMockRecords(_ records: [Record]) {
        mockRecordRepository = MockRecordRepository(mockRecords: records)
        sut = StatisticsViewModel(repository: mockRecordRepository)
    }
    
}
