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
    
    private(set) var recordToday: Record = Record()
    private(set) var recordsThisWeek: [Record] = []
    private(set) var recordsThisMonth: [Record] = []
    private(set) var allRecords: [Record] = []
    
    // MARK: - Init
    // TODO: Initialise all records
    private init() {}
    
    // MARK: - Computed properties
    var isSessionFinished: Bool { pomodoroTimer.isSessionFinished }
    
    // MARK: - Functions
    // FIXME: Remove, just for testing
    func addRecord() {
        let record = Record(date: Date.distantFuture, workSessionsCompleted: 0, dailyTarget: 0)
        let record2 = Record(date: Date.distantPast, workSessionsCompleted: 0, dailyTarget: 0)
        
        performFunctionAndFetchRecords {
            dataService.addRecord(record)
        }
        performFunctionAndFetchRecords {
            dataService.addRecord(record2)
        }
        
        guard let monthRange = Calendar.current.dateInterval(of: .month, for: Date.now) else {
            return
        }
        var currentDate = monthRange.start
        
        while currentDate < monthRange.end {
            print(currentDate)
            
            let record3 = Record(date: currentDate, workSessionsCompleted: 0, dailyTarget: 0)
            performFunctionAndFetchRecords {
                dataService.addRecord(record3)
            }
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            
            currentDate = nextDate
        }
        allRecords = dataService.fetchAllRecords()

    }
    
    func updateRecordToday() {
        recordToday = dataService.fetchRecordToday()
    }
    
    func updateRecordsThisWeek() {
        recordsThisWeek = dataService.fetchRecordsThisWeek()
    }
    
    func updateRecordsThisMonth() {
        recordsThisMonth = dataService.fetchRecordsThisMonth()
    }
    
    func updateAllRecords() {
        allRecords = dataService.fetchAllRecords()
    }
    
    func deleteAllRecords() {
        performFunctionAndFetchRecords {
            dataService.deleteAllRecords()
        }
    }
    
    func deleteRecord(_ indexSet: IndexSet) {
        for index in indexSet {
            let record = allRecords[index]
            dataService.deleteRecord(record)
        }
        
        allRecords = dataService.fetchAllRecords()
    }
    
    // MARK: - Private functions
    private func performFunctionAndFetchRecords(_ operation: () -> Void) {
        operation()
        allRecords = dataService.fetchAllRecords()
    }
}
