//
//  RecordRepository.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 07/10/2024.
//

import Foundation
import SwiftData

// FIXME: Fix warning 'Main actor-isolated static property shared...'
final class RecordRepository {
    @MainActor
    static public let shared = RecordRepository()
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: Record.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func createRecord(_ record: Record) {
        modelContext.insert(record)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
        
    func readRecord(byDate date: Date) -> Record? {
        let normalisedDate = Calendar.current.startOfDay(for: date)

        let descriptor = FetchDescriptor<Record>(
            predicate: #Predicate { record in
                record.date == normalisedDate
            }
        )
        
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func readAllRecords() -> [Record] {
        let descriptor = FetchDescriptor<Record>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteRecord(_ record: Record) {
        modelContext.delete(record)
    }
    
    func deleteAllRecords() {
        do {
            try modelContext.delete(model: Record.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
