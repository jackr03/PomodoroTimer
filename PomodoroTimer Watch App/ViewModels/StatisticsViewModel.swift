//
//  StatisticsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import Observation

@Observable
final class StatisticsViewModel {
    
    // MARK: - Stored properties
    private let repository: RecordRepositoryProtocol
    
    private(set) var records: [Record] = []
    
    // MARK: - Inits
    @MainActor
    init(repository: RecordRepositoryProtocol? = nil) {
        self.repository = repository ?? RecordRepository.shared
        
        fetchAllRecords()
    }
        
    // MARK: - Computed properties
    /**
     Returns today's record, or a placeholder record if one was not found
     */
    var recordToday: Record {
        records.filter { record in
            record.date == Calendar.current.startOfToday
        }
        .first ?? Record()
    }
    
    var recordsThisWeek: [Record] {
        recordsForWeek(date: Date.now)
    }
    
    var recordsThisMonth: [Record] {
        recordsForMonth(date: Date.now)
    }
    
    var totalSessions: Int {
        return records.reduce(0, { sum, record in
            sum + record.sessionsCompleted
        })
    }
    
    var currentStreak: Int {
        streak(for: Date.now)
    }
    
    var longestStreak: Int {
        var currentStreak = 0
        var longestStreak = 0
       
        for i in 0..<records.count {
            let currentRecord = records[i]
            
            // Check if current record is the first one or the day after the previous
            let isConsecutive = i == 0 || Calendar.current.isDate(records[i - 1].date,
                                                    inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: currentRecord.date)!)
            
            if isConsecutive && currentRecord.isDailyTargetMet {
                currentStreak += 1
            } else {
                longestStreak = max(currentStreak, longestStreak)
                currentStreak = currentRecord.isDailyTargetMet ? 1 : 0
            }
        }
        
        return max(currentStreak, longestStreak)
    }
    
    var totalTimeSpent: String {
        let totalSeconds = records.reduce(0, { sum, record in
            sum + record.timeSpent
        })
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return "\(hours)h \(minutes)m \(seconds)s"
    }
    
    // MARK: - Functions
    func fetchAllRecords() {
        records = repository.readAllRecords()
    }
    
    func addNewRecord() -> Record {
        let newRecord = Record()
        
        performFunctionAndFetchRecords {
            repository.createRecord(newRecord)
        }
        
        return newRecord
    }
    
    func deleteAllRecords() {
        performFunctionAndFetchRecords {
            repository.deleteAllRecords()
        }
    }
    
    func recordsForWeek(date: Date) -> [Record] {
        let weekRange = Calendar.current.weekRange(for: date)
        
        return records.filter { record in
            record.date >= weekRange.lowerBound && record.date < weekRange.upperBound
        }
    }
    
    func recordsForMonth(date: Date) -> [Record] {
        let monthRange = Calendar.current.monthRange(for: date)
        
        return records.filter { record in
            record.date >= monthRange.lowerBound && record.date < monthRange.upperBound
        }
    }
    
    func streak(for date: Date) -> Int {
        var currentStreak = 0
        var currentDate = Calendar.current.startOfDay(for: date)
        
        while let record = records.first(where: { $0.date == currentDate }) {
            if record.isDailyTargetMet {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    // MARK: - Private functions
    private func performFunctionAndFetchRecords(_ operation: () -> Void) {
        operation()
        fetchAllRecords()
    }
}
