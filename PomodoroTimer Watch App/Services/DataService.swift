//
//  DataService.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 07/10/2024.
//

import Foundation
import SwiftData

final class DataService {
    @MainActor
    static public let shared = DataService()
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: Record.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchRecords(with descriptor: FetchDescriptor<Record>) -> [Record] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // Attempt to fetch the record for today
    // If it doesn't exist, then create a new one and return that
    func fetchRecordToday() -> Record {
        let normalisedDate = Calendar.current.startOfDay(for: Date.now)

        let descriptor = FetchDescriptor<Record>(
            predicate: #Predicate { record in
                record.date == normalisedDate
            }
        )
        
        if let record = fetchRecords(with: descriptor).first {
            return record
        } else {
            let newRecord = Record()
            addRecord(newRecord)
            
            return newRecord
        }
    }
    
    // TODO: Log issues properly if dateIntervals cannot be found
    func fetchRecordsThisWeek() -> [Record] {
        let weekRange = Calendar.current.currentWeekRange
        
        var descriptor = FetchDescriptor<Record>(
            predicate: #Predicate { record in
                record.date >= weekRange.lowerBound && record.date < weekRange.upperBound
            },
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 7
        
        return fetchRecords(with: descriptor)
    }
    
    func fetchRecordsThisMonth() -> [Record] {
        guard let monthRange = Calendar.current.dateInterval(of: .month, for: Date.now) else {
            return []
        }
        
        var descriptor = FetchDescriptor<Record>(
            predicate: #Predicate { record in
                record.date >= monthRange.start && record.date < monthRange.end
            },
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 31
        
        return fetchRecords(with: descriptor)
    }
    
    func fetchAllRecords() -> [Record] {
        let descriptor = FetchDescriptor<Record>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        return fetchRecords(with: descriptor)
    }
    
    func addRecord(_ record: Record) {
        modelContext.insert(record)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteAllRecords() {
        do {
            try modelContext.delete(model: Record.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteRecord(_ record: Record) {
        modelContext.delete(record)
    }
}
