//
//  MockRecordRepository.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 18/11/2024.
//

import Foundation
@testable import PomodoroTimer

final class MockRecordRepository: RecordRepositoryProtocol {
    
    // MARK: - Stored properties
    var mockRecords: [Record]
    
    // MARK: - Inits
    init(mockRecords: [Record]) {
        self.mockRecords = mockRecords
    }
    
    // MARK: - Functions
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
    
    
    func deleteRecord(_ record: Record) {
        if let index = mockRecords.firstIndex(where: {
            $0.date == record.date
        }) {
            mockRecords.remove(at: index)
        }
    }
    
    func deleteAllRecords() {
        mockRecords.removeAll()
    }
}
