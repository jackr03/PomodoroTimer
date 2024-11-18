//
//  MockRecordRepository.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 18/11/2024.
//

import Foundation
@testable import PomodoroTimer

final class MockRecordRepository: RecordRepositoryProtocol {
    
    var mockRecords: [Record]
    
    // MARK: - Inits
    init(mockRecords: [Record]) {
        self.mockRecords = mockRecords
    }
    
    // MARK: - Mock implementations
    func createRecord(_ record: Record) {
        mockRecords.append(record)
    }

    func readRecord(byDate date: Date) -> Record? {
        let normalisedDate = Calendar.current.startOfDay(for: date)
        
        return mockRecords.first { record in
            record.date == normalisedDate
        }
    }
    
    func readAllRecords() -> [Record] {
        return mockRecords
    }
    
    // MARK: - No-Op implementations
    func deleteRecord(_ record: Record) {}
    func deleteAllRecords() {}
}
