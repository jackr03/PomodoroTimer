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
    
    var navigationBarTitle: XCUIElement { app.navigationBars.staticTexts["Settings"] }
    var backButton: XCUIElement { app.navigationBars.buttons["BackButton"].firstMatch }
    
    var workDurationPicker: XCUIElement { app.otherElements["workDurationPicker"] }
    var shortBreakDurationPicker: XCUIElement { app.otherElements["shortBreakDurationPicker"] }
    var longBreakDurationPicker: XCUIElement { app.otherElements["longBreakDurationPicker"] }
    var dailyTargetPicker: XCUIElement { app.otherElements["dailyTargetPicker"] }
    var autoContinueSwitch: XCUIElement { app.switches["autoContinueSwitch"].switches.firstMatch }
    
    var resetSettingsButton: XCUIElement { app.buttons["resetSettingsButton"] }
}
