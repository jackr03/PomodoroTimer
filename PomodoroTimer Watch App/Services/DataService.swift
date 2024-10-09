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
    
    // TODO: Rename to follow CRUD name scheme
    func fetchRecords(with descriptor: FetchDescriptor<Record>) -> [Record] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // TODO: Remove specific, and just have a generic readRecord() function that takes a date. If it doesn't exist, create a new one and return that
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
