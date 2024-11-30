
//
//  PomodoroScreen.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest

class PomodoroScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var statisticsButton: XCUIElement { app.buttons["statisticsButton"].firstMatch }
    var settingsButton: XCUIElement { app.buttons["settingsButton"].firstMatch }
    var settingsButtonWithWarning: XCUIElement { app.buttons["settingsButtonWithWarning"].firstMatch }
    var playButton: XCUIElement { app.buttons["playButton"] }
    var pauseButton: XCUIElement { app.buttons["pauseButton"] }
    var stopButton: XCUIElement { app.buttons["stopButton"] }
    var resetButton: XCUIElement { app.buttons["resetButton"] }
    var skipButton: XCUIElement { app.buttons["skipButton"] }
}
