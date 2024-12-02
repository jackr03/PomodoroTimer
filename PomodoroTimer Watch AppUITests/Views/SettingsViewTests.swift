//
//  SettingsViewTests.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 02/12/2024.
//

import XCTest

final class SettingsViewTests: XCTestCase {

    private var app: XCUIApplication!
    private var sut: SettingsScreen!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        sut = SettingsScreen(app: app)
        
        // Wait for settings screen to be visible first
        app.buttons["settingsButton"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3),
                      "Settings screen should be visible within 3 seconds")
    }

    override func tearDown() {
        app = nil
        sut = nil
        super.tearDown()
    }

    func testSettingsForm_rendersProperly() {
        XCTAssertTrue(sut.workDurationPicker.exists, "Work duration picker should render properly")
        XCTAssertTrue(sut.shortBreakDurationPicker.exists, "Short break duration picker should render properly")
        XCTAssertTrue(sut.longBreakDurationPicker.exists, "Long break duration picker should render properly")
        
        app.swipeUp()
        
        XCTAssertTrue(sut.dailyTargetPicker.exists, "Daily target picker should render properly")
        XCTAssertTrue(sut.autoContinueSwitch.exists, "Auto-continue switch should render properly")
    }
}
