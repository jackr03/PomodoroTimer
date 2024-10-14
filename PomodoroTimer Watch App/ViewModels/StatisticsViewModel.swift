//
//  StatisticsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class StatisticsViewModel {
    // MARK: - Properties
    static let shared = StatisticsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    private let dataService = DataService.shared
    
    private(set) var records: [Record] = []
    
    // MARK: - Init
    private init() {
        self.records = dataService.fetchAllRecords()
    }
    
    // MARK: - Computed properties
    var recordToday: Record {
        records.filter { record in
            record.date == Calendar.current.startOfToday
        }
        .first ?? addNewRecord()
    }
    
    var recordsThisWeek: [Record] {
        let weekRange = Calendar.current.currentWeekRange
        
        return records.filter { record in
            record.date >= weekRange.lowerBound && record.date < weekRange.upperBound
        }
    }
    
    var recordsThisMonth: [Record] {
        let monthRange = Calendar.current.currentMonthRange
        
        return records.filter { record in
            record.date >= monthRange.lowerBound && record.date < monthRange.upperBound
        }
    }
    
    var totalSessions: Int {
        return records.reduce(0, { sum, record in
            sum + record.sessionsCompleted
        })
    }
    
    var currentStreak: Int {
        var currentStreak = 0
        var currentDate = Calendar.current.startOfToday
        
        for record in records {
            guard Calendar.current.isDate(record.date, inSameDayAs: currentDate), record.isDailyTargetMet else {
                break
            }
            
            currentStreak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return currentStreak
    }
    
    var longestStreak: Int {
        var currentStreak = 0
        var longestStreak = 0
        var currentDate = Calendar.current.startOfToday
        
        for record in records {
            if Calendar.current.isDate(record.date, inSameDayAs: currentDate) && record.isDailyTargetMet {
                currentStreak += 1
            } else {
                longestStreak = max(currentStreak, longestStreak)
                currentStreak = 0
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        longestStreak = max(currentStreak, longestStreak)
        
        return longestStreak
    }
    
    var isSessionFinished: Bool { pomodoroTimer.isSessionFinished }
    
    // MARK: - Functions
    // TODO: Remove, just for testing
    func addRecord() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let firstOfOctober = calendar.date(from: DateComponents(year: 2024, month: 10, day: 1))!

        // Start looping from the 1st of October to today
        var currentDate = firstOfOctober
        while currentDate <= today {
                let record = Record(date: currentDate, sessionsCompleted: Int.random(in: 1...12), dailyTarget: 4)
                performFunctionAndFetchRecords {
                    dataService.addRecord(record)
                }
                
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        records = dataService.fetchAllRecords()
    }
    
    func addNewRecord() -> Record {
        let newRecord = Record()
        
        performFunctionAndFetchRecords {
            dataService.addRecord(newRecord)
        }
        
        return newRecord
    }
    
    func fetchRecords() {
        records = dataService.fetchAllRecords()
    }
    
    func deleteAllRecords() {
        performFunctionAndFetchRecords {
            dataService.deleteAllRecords()
        }
    }
    
    func deleteRecord(_ record: Record) {
        performFunctionAndFetchRecords {
            dataService.deleteRecord(record)
        }
    }
    
    // MARK: - Private functions
    private func performFunctionAndFetchRecords(_ operation: () -> Void) {
        operation()
        records = dataService.fetchAllRecords()
    }
}
