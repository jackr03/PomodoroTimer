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
    
    func fetchRecords() -> [Record] {
        do {
            return try modelContext.fetch(FetchDescriptor<Record>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchRecordByDate(_ date: Date) -> Record {
        var descriptor = FetchDescriptor<Record>(
            predicate: #Predicate { $0.date == date }
        )
        descriptor.fetchLimit = 1
        
        do {
            return try modelContext.fetch(descriptor)[0]
        } catch {
            fatalError(error.localizedDescription)
        }
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
