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
    
    // MARK: - Computed properties
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
}
