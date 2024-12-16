//
//  Record.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 05/10/2024.
//

import Foundation
import SwiftData

@Model
class Record {
    
    // MARK: - Stored properties
    @Attribute(.unique) var date: Date
    var sessionsCompleted: Int
    var dailyTarget: Int
    var timeSpent: Int
    
    // MARK: - Inits
    init(
        date: Date = Date.now,
        sessionsCompleted: Int = 0,
        dailyTarget: Int = SettingsManager.shared.get(.dailyTarget),
        timeSpent: Int = 0
    ) {
        let normalisedDate = Calendar.current.startOfDay(for: date)
        
        self.date = normalisedDate
        self.sessionsCompleted = sessionsCompleted
        self.dailyTarget = dailyTarget
        self.timeSpent = timeSpent
    }
    
    // MARK: - Computed properties
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
    
    var formattedTimeSpent: String {
        let hours = timeSpent / 3600
        let minutes = (timeSpent % 3600) / 60
        let seconds = timeSpent % 60
        
        return "\(hours)h \(minutes)m \(seconds)s"
    }
    
    // MARK: - Functions
    func incrementSessionsCompleted() {
        sessionsCompleted += 1
    }
    
    func addTimeSpent(_ time: Int) {
        self.timeSpent += time
    }
    
    func formattedDate(_ dateStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}
