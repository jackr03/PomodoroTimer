//
//  RecordViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 19/10/2024.
//

import Foundation

final class RecordViewModel {
    
    // MARK: - Stored properties
    private let record: Record
    private let repository: RecordRepositoryProtocol
    
    // MARK: - Inits
    // TODO: Inject the repository instead of using a singleton
    @MainActor
    init(record: Record, repository: RecordRepositoryProtocol = RecordRepository.shared) {
        self.record = record
        self.repository = repository
    }
    
    // MARK: - Functions
    func deleteRecord() {
        repository.deleteRecord(self.record)
    }
    
}
