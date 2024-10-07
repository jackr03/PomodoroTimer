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
        self.records = dataService.fetchRecords()
    }
    
    // MARK: - Computed properties
    var isSessionFinished: Bool { pomodoroTimer.isSessionFinished }
    
    // MARK: - Functions
    func addNewRecord() {
        let record = Record()
        
        performFunctionAndFetchRecords {
            dataService.addRecord(record)
        }
    }
    
    func fetchRecordByDate(_ date: Date) -> Record {
        return dataService.fetchRecordByDate(date)
    }
    
    func deleteAllRecords() {
        performFunctionAndFetchRecords {
            dataService.deleteAllRecords()
        }
    }
    
    func deleteRecord(_ indexSet: IndexSet) {
        for index in indexSet {
            let record = records[index]
            dataService.deleteRecord(record)
        }
        records = dataService.fetchRecords()
    }
    
    // MARK: - DEPRECATED
    // TODO: Reset using SwiftData
    func resetSessions() {
        Defaults.set("sessionsCompletedToday", to: 0)
        Defaults.set("totalSessionsCompleted", to: 0)
    }
    
    // MARK: - Private functions
    private func performFunctionAndFetchRecords(_ operation: () -> Void) {
        operation()
        records = dataService.fetchRecords()
    }
}
