//
//  TestHelpers.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 18/11/2024.
//

import Foundation

func createDate(year: Int, month: Int, day: Int) -> Date {
    return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}
