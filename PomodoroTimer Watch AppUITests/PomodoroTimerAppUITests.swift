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
    
    private func createCarousel() -> XCUIApplication {
        return XCUIApplication(bundleIdentifier: "com.apple.Carousel")
    }
    
    func testViewPops_backToRootWhenSessionCompletes() {
        launchApp(with: ["-workDuration", "3"])
        
        pomodoroScreen.playButton.waitAndTap()
        pomodoroScreen.settingsButton.waitAndTap()
        XCTAssertTrue(settingsScreen.navigationBar.waitForNonExistence(timeout: 5), "Should no longer be on settings screen")
        XCTAssertTrue(pomodoroScreen.timesUpMessage.waitForExistence(timeout: 5), "Should show 'Times up!' message")
    }
    
    func testUserIsNotified_whenLeavingAnActiveWorkSession() {
        launchApp()
        let carousel = createCarousel()
        
        pomodoroScreen.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(carousel.otherElements["Stay focused!, Your pomodoro will be paused until you return to the app."].waitForExistence(timeout: 5), "Should show notification prompting user to return to app")
    }
    
    func testUserIsNotNotified_whenLeavingABreakSession() {
        launchApp()
        let carousel = createCarousel()
        
        pomodoroScreen.skipButton.waitAndTap()
        pomodoroScreen.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertFalse(carousel.otherElements["Stay focused!, Your pomodoro will be paused until you return to the app."].waitForExistence(timeout: 5), "Should not show notification prompting user to return to app")
    }
    
    func testUserIsNotified_whenBreakIsOver() {
        launchApp(with: ["-shortBreakDuration", "3"])
        let carousel = createCarousel()
        
        pomodoroScreen.skipButton.waitAndTap()
        pomodoroScreen.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(carousel.otherElements["Break's over!, Time to get back to work."].waitForExistence(timeout: 10), "Should show notification letting user know session is over")
    }
    
    func testTimerDoesNotGoDown_whenLeavingAnActiveWorkSession() {
        launchApp()
        let carousel = createCarousel()
        
        pomodoroScreen.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        
        carousel.cells["Open app"].waitAndTap(timeout: 5)
        XCTAssertTrue(pomodoroScreen.remainingTime.waitForExistence(timeout: 3))
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "24:59", "Timer should only have just started counting down")
    }
 
    func testChangingDurationSetting_resetsTimerIfNotAlreadyInProgress() {
        launchApp()
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.waitAndTap()
        app.buttons["3 minutes"].waitAndTap()
        XCTAssertTrue(settingsScreen.workDurationPicker.label == "Work, 3 minutes", "Work duration should be set to 3 minutes")
        
        settingsScreen.backButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "03:00", "Time should be reset to 3:00")
    }
    
    func testChangingDurationSetting_resetsTimerIfNoTimeElapsed() {
        launchApp()
        
        // Click play twice
        pomodoroScreen.playButton.tap()
        pomodoroScreen.pauseButton.tap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "25:00", "Time should still be 25:00")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.waitAndTap()
        app.buttons["3 minutes"].waitAndTap()
        XCTAssertTrue(settingsScreen.workDurationPicker.label == "Work, 3 minutes", "Work duration should be set to 3 minutes")
        
        settingsScreen.backButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.remainingTime.label == "03:00", "Time should be reset to 3:00")
    }
    
    func testChangingDurationSetting_doesNotResetTimerIfInProgress() {
        launchApp()

        pomodoroScreen.playButton.waitAndTap()
        XCTAssertTrue(pomodoroScreen.pauseButton.exists, "Timer should start")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.waitAndTap()
        app.buttons["3 minutes"].waitAndTap()
        XCTAssertTrue(settingsScreen.workDurationPicker.label == "Work, 3 minutes", "Work duration should be set to 3 minutes")
        
        settingsScreen.backButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "03:00", "Time should not be reset to 3:00")
    }
    
    func testChangingDurationSetting_doesNotResetTimerIfInProgressButPaused() {
        launchApp()

        pomodoroScreen.playButton.waitAndTap()
        pomodoroScreen.pauseButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "25:00", "Timer should have elapsed")
        XCTAssertTrue(pomodoroScreen.playButton.exists, "Timer should be paused")
        
        pomodoroScreen.settingsButton.waitAndTap()
        settingsScreen.workDurationPicker.waitAndTap()
        app.buttons["3 minutes"].waitAndTap()
        XCTAssertTrue(settingsScreen.workDurationPicker.label == "Work, 3 minutes", "Work duration should be set to 3 minutes")
        
        settingsScreen.backButton.waitAndTap()
        XCTAssertFalse(pomodoroScreen.remainingTime.label == "03:00", "Time should not be reset to 3:00")
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
