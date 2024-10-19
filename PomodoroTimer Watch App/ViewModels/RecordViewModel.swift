//
//  RecordViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 19/10/2024.
//

import Foundation

final class RecordViewModel {
    // MARK: - Properties
    private let repository = RecordRepository.shared
    
    // MARK: - Functions
    func deleteRecord(_ record: Record) {
        repository.deleteRecord(record)
    }
}
