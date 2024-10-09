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
        let monthRange = Calendar.current.currentMonthRange
        
        var currentDate = monthRange.lowerBound
        while currentDate < monthRange.upperBound {
            if Bool.random() {
                let record = Record(date: currentDate, sessionsCompleted: Int.random(in: 1...12), dailyTarget: 8)
                performFunctionAndFetchRecords {
                    dataService.addRecord(record)
                }
            }
                
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        allRecords = dataService.fetchAllRecords()
    }
    
    func updateRecordToday() {
        recordToday = dataService.fetchRecordToday()
    }
    
    // FIXME: Clean up the way we get the indexes, e.g. use a dictionary?
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
