//
//  SettingsViewModelTests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 16/12/2024.
//

import Testing
@testable import PomodoroTimer

final class SettingsViewModelTests {
    
    var sut: SettingsViewModel!
    var mockRecordRepository: MockRecordRepository!
    
    init() {}
    
    deinit {
        sut = nil
        mockRecordRepository = nil
    }
    
    private func setUp(_ records: [Record] = []) async {
        mockRecordRepository = MockRecordRepository(mockRecords: records)
        sut = await SettingsViewModel(repository: mockRecordRepository)
    }
    
    @Test
    func updateRecordDailyTarget_updatesRecordCorrectly() async {
        let record = Record(dailyTarget: 8)
        await setUp([record])
        
        sut.updateRecordDailyTarget(to: 12)
        #expect(record.dailyTarget == 12, "Should update today's record correctly")
    }
}
