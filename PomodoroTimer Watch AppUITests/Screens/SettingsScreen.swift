//
//  SettingsScreen.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 02/12/2024.
//

import XCTest

class SettingsScreen {
    private let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
        
    var workDurationPicker: XCUIElement { app.buttons["workDurationPicker"] }
    var shortBreakDurationPicker: XCUIElement { app.buttons["shortBreakDurationPicker"] }
    var longBreakDurationPicker: XCUIElement { app.buttons["longBreakDurationPicker"] }
    var dailyTargetPicker: XCUIElement { app.buttons["dailyTargetPicker"] }
    var autoContinueSwitch: XCUIElement { app.switches["autoContinueSwitch"] }
}
