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
    @Attribute(.unique) var date: Date
    var workSessionsCompleted: Int
    var dailyTarget: Int
    var isDailyTargetMet: Bool
    
    public init(date: Date, workSessionsCompleted: Int, dailyTarget: Int, isDailyTargetMet: Bool) {
        self.date = Calendar.current.startOfDay(for: date)
        self.workSessionsCompleted = workSessionsCompleted
        self.dailyTarget = dailyTarget
        self.isDailyTargetMet = isDailyTargetMet
    }
    
    convenience init() {
        self.init(date: Date.now, workSessionsCompleted: 0, dailyTarget: NumberSetting.dailyTarget.currentValue, isDailyTargetMet: false)
    }
}
