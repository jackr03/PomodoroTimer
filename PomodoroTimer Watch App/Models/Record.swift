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
    // MARK: - Properties
    @Attribute(.unique) var date: Date
    var sessionsCompleted: Int
    var dailyTarget: Int
    
    // MARK: - Inits
    public init(date: Date, sessionsCompleted: Int, dailyTarget: Int) {
        self.date = Calendar.current.startOfDay(for: date)
        self.sessionsCompleted = sessionsCompleted
        self.dailyTarget = dailyTarget
    }
    
    convenience init() {
        self.init(date: Date.now, sessionsCompleted: 0, dailyTarget: NumberSetting.dailyTarget.currentValue)
    }
}

extension Record {
    var formattedDateShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: date)

    }
    
    var formattedDateMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
}
