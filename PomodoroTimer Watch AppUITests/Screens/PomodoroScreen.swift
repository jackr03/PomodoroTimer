//
//  PomodoroScreen.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest

final class PomodoroScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var statisticsButton: XCUIElement { app.buttons["statisticsButton"].firstMatch }
    var settingsButton: XCUIElement { app.buttons["settingsButton"].firstMatch }
    var settingsButtonWithWarning: XCUIElement { app.buttons["settingsButtonWithWarning"].firstMatch }
    var stopButton: XCUIElement { app.buttons["stopButton"] }
    var resetButton: XCUIElement { app.buttons["resetButton"] }
    var skipButton: XCUIElement { app.buttons["skipButton"] }
    
    var actionButton: XCUIElement { app.buttons["actionButton"] }
    
    var currentSession: XCUIElement { app.staticTexts["currentSession"] }
    var sessionProgress: XCUIElement { app.staticTexts["sessionProgress"] }
    var remainingTime: XCUIElement { app.staticTexts["remainingTime"] }
    var playButton: XCUIElement { actionButton.images["playButton"] }
    var pauseButton: XCUIElement { actionButton.images["pauseButton"] }
    
    var timesUpMessage: XCUIElement { app.staticTexts["timesUpMessage"] }
    var completeSessionButton: XCUIElement { actionButton.images["completeSessionButton"] }
}
