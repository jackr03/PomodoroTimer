//
//  SettingsScreen.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 02/12/2024.
//

import XCTest

final class SettingsScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
        
    var navigationBar: XCUIElement { app.navigationBars["Settings"] }
    var backButton: XCUIElement { app.navigationBars.buttons["BackButton"].firstMatch }
    
    var workDurationPicker: XCUIElement { app.buttons["workDurationPicker"] }
    var shortBreakDurationPicker: XCUIElement { app.buttons["shortBreakDurationPicker"] }
    var longBreakDurationPicker: XCUIElement { app.buttons["longBreakDurationPicker"] }
    var dailyTargetPicker: XCUIElement { app.buttons["dailyTargetPicker"] }
    var autoContinueSwitch: XCUIElement { app.switches["autoContinueSwitch"].switches.firstMatch }
    
    var resetSettingsButton: XCUIElement { app.buttons["resetSettingsButton"] }
}
