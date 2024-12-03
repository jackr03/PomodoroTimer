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
    
    func weekRange(for date: Date = Date.now) -> ClosedRange<Date> {
        if let weekRange = self.dateInterval(of: .weekOfYear, for: date) {
            return weekRange.start...weekRange.end
        } else {
            return Date.now...Date.now
        }
    }
    
    func monthRange(for date: Date = Date.now) -> ClosedRange<Date> {
        if let monthRange = self.dateInterval(of: .month, for: date) {
            return monthRange.start...monthRange.end
        } else {
            return Date.now...Date.now
        }
    }
}
