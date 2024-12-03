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
    }

    override func tearDown() {
        app = nil
        sut = nil
        super.tearDown()
    }
    
    private func launchApp(with arguments: [String] = []) {
        app.launchArguments += arguments
        
        app.launch()
        sut = SettingsScreen(app: app)
        app.buttons["settingsButton"].firstMatch.waitAndTap()
        XCTAssertTrue(sut.navigationBar.waitForExistence(timeout: 3),
                      "Settings screen should be visible within 3 seconds")
    }
    
    func testSettingsForm_rendersProperly() {
        launchApp()
        
        XCTAssertTrue(sut.workDurationPicker.exists, "Work duration picker should render properly")
        XCTAssertTrue(sut.shortBreakDurationPicker.exists, "Short break duration picker should render properly")
        XCTAssertTrue(sut.longBreakDurationPicker.exists, "Long break duration picker should render properly")
        
        app.swipeUp()
        XCTAssertTrue(sut.dailyTargetPicker.exists, "Daily target picker should render properly")
        XCTAssertTrue(sut.autoContinueSwitch.exists, "Auto-continue switch should render properly")
    }
    
    func testResetSettingsButton_rendersIfSettingsNotDefault() {
        launchApp()
        
        app.swipeUp()
        XCTAssertFalse(sut.resetSettingsButton.exists, "Reset settings button should not render if settings are all default")

        sut.autoContinueSwitch.waitAndTap()
        XCTAssertTrue(sut.resetSettingsButton.exists, "Reset settings button should render after a setting is changed")
    }
}
