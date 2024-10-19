//
//  Utilities.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation
import WatchKit

extension Calendar {
    var startOfToday: Date { Calendar.current.startOfDay(for: Date.now) }
    
    var currentWeekRange: ClosedRange<Date> {
        if let weekRange = self.dateInterval(of: .weekOfYear, for: Date.now) {
            return weekRange.start...weekRange.end
        } else {
            return Date.now...Date.now
        }
    }
    
    var currentMonthRange: ClosedRange<Date> {
        if let monthRange = self.dateInterval(of: .month, for: Date.now) {
            return monthRange.start...monthRange.end
        } else {
            return Date.now...Date.now
        }
    }
}
