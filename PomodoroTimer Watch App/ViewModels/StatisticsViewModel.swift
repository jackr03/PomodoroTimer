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
        return 5
    }
    
    var currentStreak: Int {
        return 10
    }
    
    var longestStreak: Int {
        return 12
    }
    
    var isSessionFinished: Bool { pomodoroTimer.isSessionFinished }
    
    // MARK: - Functions
    // TODO: Remove, just for testing
    func addRecord() {
        let monthRange = Calendar.current.currentMonthRange
        
        var currentDate = monthRange.lowerBound
        while currentDate < monthRange.upperBound {
            if Bool.random() {
                let record = Record(date: currentDate, sessionsCompleted: Int.random(in: 1...12), dailyTarget: 6)
                performFunctionAndFetchRecords {
                    dataService.addRecord(record)
                }
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
