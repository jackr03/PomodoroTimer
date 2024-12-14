//
//  RecordViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 19/10/2024.
//

import Foundation

final class RecordViewModel {
    
    // MARK: - Stored properties
    private let record: Record
    private let repository: RecordRepositoryProtocol
    
    // MARK: - Inits
    @MainActor
    init(
        record: Record,
        repository: RecordRepositoryProtocol? = nil
    ) {
        self.record = record
        self.repository = repository ?? RecordRepository.shared
    }
    
    // MARK: - Computed properties
    var date: Date { record.date }
    var sessionsCompleted: Int { record.sessionsCompleted }
    var dailyTarget: Int { record.dailyTarget }
    
    var isDailyTargetMet: Bool { record.isDailyTargetMet }
    var isToday: Bool { record.date == Calendar.current.startOfToday }
    
    var formattedDateShort: String { record.formattedDate(.short) }
    var formattedDateMedium: String { record.formattedDate(.medium) }
    
    var statusMessage: String {
        if record.sessionsCompleted == 0 {
            return "Let's get to work!"
        } else if record.sessionsCompleted > 0 && !record.isDailyTargetMet {
            return "Keep it up!"
        } else {
            return "Well done!"
        }
    }
    
    // MARK: - Functions
    func deleteRecord() {
        repository.deleteRecord(self.record)
    }
}
