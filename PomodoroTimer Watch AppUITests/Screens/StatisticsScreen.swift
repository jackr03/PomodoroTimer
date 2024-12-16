//
//  StatisticsScreen.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 16/12/2024.
//

import XCTest

final class StatisticsScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var dailyTitle: XCUIElement { app.navigationBars.staticTexts["Today"] }
    var dailyProgressBar: XCUIElement { app.progressIndicators["dailyProgressBar"] }
    var dailySessionsCompleted: XCUIElement { app.staticTexts["dailySessionsCompleted"] }
    var dailyTimeSpent: XCUIElement { app.staticTexts["dailyTimeSpent"] }
    var dailyStatusMessage: XCUIElement { app.staticTexts["dailyStatusMessage"] }
    
    var weeklyTitle: XCUIElement { app.navigationBars.staticTexts["This week"] }
    var weeklyChart: XCUIElement { app.otherElements["weeklyChart"] }
    
    var monthlyTitle: XCUIElement { app.navigationBars.staticTexts["This month"] }
    var monthlyChart: XCUIElement { app.otherElements["monthlyChart"] }
    
    var allTimeTitle: XCUIElement { app.navigationBars.staticTexts["All time"] }
    var allTimeSummary: XCUIElement { app.staticTexts["Summary"] }
    var deleteAllRecordsButton: XCUIElement { app.buttons["deleteAllRecordsButton"] }
}
