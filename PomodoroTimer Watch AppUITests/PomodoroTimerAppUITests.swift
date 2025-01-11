//
//  PomodoroTimerAppUITests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest
@testable import PomodoroTimer

final class PomodoroTimerAppUITests: XCTestCase {
    
    private var app: XCUIApplication!
    private var pomodoroScreen: PomodoroScreen!
    private var settingsScreen: SettingsScreen!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        pomodoroScreen = nil
        settingsScreen = nil
        super.tearDown()
    }
    
    private func launchApp(with arguments: [String] = []) {
        app.launchArguments += arguments
        
        app.launch()
        pomodoroScreen = PomodoroScreen(app: app)
        settingsScreen = SettingsScreen(app:app)
    }
    
    func testViewPops_backToRootWhenSessionCompletes() {
        launchApp(with: ["-workDuration", "3"])
        
        pomodoroScreen.playButton.waitAndTap()
        pomodoroScreen.settingsButton.waitAndTap()
        XCTAssertTrue(settingsScreen.navigationBarTitle.waitForNonExistence(timeout: 5), "Should no longer be on settings screen")
        XCTAssertTrue(pomodoroScreen.timesUpMessage.waitForExistence(timeout: 5), "Should show 'Times up!' message")
    }
 
    func testChangingDurationSetting_resetsTimerIfNotAlreadyInProgress() {
        launchApp()
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.swipeDown()
        settingsScreen.backButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "16:00", "Time should be reset to 16:00")
    }
    
    func testChangingDurationSetting_resetsTimerIfNoTimeElapsed() {
        launchApp()
        
        // Click play twice
        pomodoroScreen.playButton.tap()
        pomodoroScreen.pauseButton.tap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "25:00", "Time should still be 25:00")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.swipeDown()
        settingsScreen.backButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "16:00", "Time should be reset to 16:00")
    }
    
    func testChangingDurationSetting_doesNotResetTimerIfInProgress() {
        launchApp()

        pomodoroScreen.playButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.pauseButton.exists, "Timer should start")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.swipeDown()
        XCTAssertTrue(settingsScreen.workDurationPicker.value as! String == "16", "Work duration should be set to 16 minutes")
        
        settingsScreen.backButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "16:00", "Time should not be reset to 16:00")
    }
    
    func testChangingDurationSetting_doesNotResetTimerIfInProgressButPaused() {
        launchApp()

        pomodoroScreen.playButton.waitAndTap()
        pomodoroScreen.pauseButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "25:00", "Timer should have elapsed")
        XCTAssertTrue(pomodoroScreen.playButton.exists, "Timer should be paused")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.swipeDown()
        settingsScreen.backButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "16:00", "Time should not be reset to 16:00")
    }
    
    func testAutoContinueSetting_worksCorrectly() {
        launchApp(with: ["-workDuration", "3",
                         "-autoContinue", "true"])
        
        pomodoroScreen.playButton.waitAndTap()
        pomodoroScreen.completeSessionButton.waitAndTap(timeout: 5)
        XCTAssertTrue(pomodoroScreen.currentSession.label == "BREAK", "Should be on a break session")
        XCTAssertTrue(pomodoroScreen.pauseButton.waitForExistence(timeout: 3), "Timer should be playing")
    }
}
