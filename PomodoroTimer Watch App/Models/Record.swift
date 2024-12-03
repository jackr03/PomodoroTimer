//
//  Record.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 05/10/2024.
//

import Foundation
import SwiftData

// TODO: Track total time done
@Model
class Record {
    
    // MARK: - Stored properties
    @Attribute(.unique) var date: Date
    var sessionsCompleted: Int
    var dailyTarget: Int
    
    // MARK: - Inits
    init(
        date: Date = Date.now,
        sessionsCompleted: Int = 0,
        dailyTarget: Int = SettingsManager.shared.get(.dailyTarget)
    ) {
        let normalisedDate = Calendar.current.startOfDay(for: date)
        
        self.date = normalisedDate
        self.sessionsCompleted = sessionsCompleted
        self.dailyTarget = dailyTarget
    }
    
    // MARK: - Computed properties
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
    
    // MARK: - Functions
    func formatDate(_ dateStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}
