//
//  StatisticsViewModelTests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 18/11/2024.
//

import Foundation
import Testing
@testable import PomodoroTimer

final class StatisticsViewModelTests {

    var sut: StatisticsViewModel!
    var mockRecordRepository: MockRecordRepository!
    
    init() {}

    deinit {
        sut = nil
        mockRecordRepository = nil
    }
    
    private func setUpWithNoRecords() async {
        mockRecordRepository = MockRecordRepository(mockRecords: [])
        await sut = StatisticsViewModel(repository: mockRecordRepository)
    }
    
    private func setUpWithMockRecords(_ records: [Record]) async {
        mockRecordRepository = MockRecordRepository(mockRecords: records)
        await sut = StatisticsViewModel(repository: mockRecordRepository)
    }
        
    @Test
    func fetchAllRecords_returnsCorrectRecords() async {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1)),
            Record(date: createDate(year: 2024, month: 1, day: 2))
        ]
        
        await setUpWithMockRecords(records)
        
        sut.fetchAllRecords()
        
        #expect(sut.records.count == 2, "Should return exactly 2 records")
    }
        
    @Test
    func addNewRecord_createsNewRecord() async {
        await setUpWithNoRecords()
        
        let newRecord = sut.addNewRecord()
        
        #expect(sut.records == [newRecord], "Should create a new record")
    }
        
    @Test
    func deleteAllRecord_removeAllRecords() async {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1)),
            Record(date: createDate(year: 2024, month: 1, day: 2))
        ]

        await setUpWithMockRecords(records)
        
        sut.deleteAllRecords()
        
        #expect(sut.records.count == 0, "Should delete all records")
    }
    
    @Test
    func fetchRecords_whenNoRecords_returnZeroOrEmptyValues() async {
        await setUpWithNoRecords()
        
        #expect(sut.recordsThisWeek.isEmpty, "Should return no records for this week")
        #expect(sut.recordsThisMonth.isEmpty, "Should return no records for this month")
        #expect(sut.totalSessions == 0, "Should return 0 for total sessions")
        #expect(sut.currentStreak == 0, "Should return 0 for current streak")
        #expect(sut.longestStreak == 0, "Should return 0 for longest streak")
    }
    
    @Test
    func recordToday_returnsTodaysRecord() async {
        let recordYesterday = Record(date: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, sessionsCompleted: 0, dailyTarget: 8)
        let recordToday = Record(date: Date.now, sessionsCompleted: 0, dailyTarget: 8)
        
        await setUpWithMockRecords([recordYesterday, recordToday])
        
        #expect(sut.recordToday == recordToday, "Should return today's record")
    }
    
    @Test
    func recordToday_whenNoRecordExists_returnsAPlaceholderRecord() async {
        await setUpWithNoRecords()
        
        #expect(sut.recordToday != nil, "Should return a placeholder record")
        #expect(sut.records.count == 0, "Should not store placeholder record into database")
        #expect(sut.recordToday.date == Calendar.current.startOfToday, "New record's date should be set to today")
        #expect(sut.recordToday.sessionsCompleted == 0, "New record should have 0 sessions completed")
        #expect(sut.recordToday.timeSpent == 0, "New record should have 0 time spent")
    }
    
    @Test
    func recordsForWeek_returnsExpectedRecords() async {
        let testDate = createDate(year: 2024, month: 1, day: 5)
        let recordInWeek1 = Record(date: createDate(year: 2024, month: 1, day: 1));
        let recordInWeek2 = Record(date: createDate(year: 2024, month: 1, day: 2));
        let recordNotInWeek = Record(date: createDate(year: 2024, month: 1, day: 31));
        
        await setUpWithMockRecords([recordInWeek1, recordInWeek2, recordNotInWeek])
        
        #expect(sut.recordsForWeek(date: testDate) == [recordInWeek1, recordInWeek2], "Records for week should contain correct records")
    }
    
    @Test
    func recordsForMonth_returnsExpectedRecords() async {
        let testDate = createDate(year: 2024, month: 1, day: 1)
        let recordInMonth1 = Record(date: createDate(year: 2024, month: 1, day: 1));
        let recordInMonth2 = Record(date: createDate(year: 2024, month: 1, day: 2));
        let recordNotInMonth = Record(date: createDate(year: 2024, month: 2, day: 1));
        
        await setUpWithMockRecords([recordInMonth1, recordInMonth2, recordNotInMonth])
        
        #expect(sut.recordsForMonth(date: testDate) == [recordInMonth1, recordInMonth2], "Records for month should contain correct records")
    }

    @Test
    func totalSessions_returnsCorrectTotalCount() async {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 5),
            Record(date: createDate(year: 2024, month: 4, day: 3), sessionsCompleted: 4),
            Record(date: createDate(year: 2024, month: 11, day: 9), sessionsCompleted: 7)
        ]
        
        await setUpWithMockRecords(records)
        
        #expect(sut.totalSessions == 16, "Total sessions should be exactly 16")
    }
    
    @Test
    func streak_forGivenDate_returnsCorrectValue() async {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 2), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 5), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 6), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 7), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        await setUpWithMockRecords(records)
        
        let mockCurrentDate = createDate(year: 2024, month: 1, day: 7)
        
        #expect(sut.streak(for: mockCurrentDate) == 3, "Streak for today should be exactly 3")
    }
    
    @Test
    func streak_spansAcrossMonthsAndYears() async {
        let records = [
            Record(date: createDate(year: 2023, month: 12, day: 31), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        await setUpWithMockRecords(records)
        
        let mockCurrentDate = createDate(year: 2024, month: 1, day: 1)

        #expect(sut.streak(for: mockCurrentDate) == 2, "Streak should span across months and years")
    }
    
    @Test
    func longestStreak_returnsCurrentLongestStreak() async {
        let records = [
            Record(date: createDate(year: 2024, month: 1, day: 1), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 2), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 3), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 30), sessionsCompleted: 8, dailyTarget: 8),
            Record(date: createDate(year: 2024, month: 1, day: 31), sessionsCompleted: 8, dailyTarget: 8)
        ]
        
        await setUpWithMockRecords(records)
        
        #expect(sut.longestStreak == 3, "Longest streak should be exactly 3")
    }
    
    @Test
    func totalTimeSpent_returnsCorrectTimeSpent() async {
        let records = [
            Record(timeSpent: 3600),
            Record(timeSpent: 60),
            Record(timeSpent: 1),
        ]
        
        await setUpWithMockRecords(records)
        
        #expect(sut.totalTimeSpent == "1h 1m 1s", "Total time should be \"1h 1m 1s\"")
    }
}
