//
//  PomodoroViewTests.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest

final class PomodoroViewTests: XCTestCase {
        
    private var app: XCUIApplication!
    private var sut: PomodoroScreen!

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
        sut = PomodoroScreen(app: app)
    }

    func testActiveSesssionView_rendersProperly() {
        launchApp()
        
        XCTAssertTrue(sut.currentSession.exists, "Current session text should render")
        XCTAssertTrue(sut.sessionProgress.exists, "Session progress text should render")
        XCTAssertTrue(sut.remainingTime.exists, "Remaining time should render")
        XCTAssertTrue(sut.actionButton.isHittable, "Action button should render")
    }
    
    func testToolbarButtons_renderProperly() {
        launchApp()
        
        XCTAssertTrue(sut.statisticsButton.exists, "Statistics button should render in the toolbar")
        XCTAssertTrue(sut.settingsButton.exists, "Settings button should render in the toolbar")
        XCTAssertTrue(sut.stopButton.exists, "Stop button should render in the toolbar")
        XCTAssertTrue(sut.resetButton.exists, "Reset button should render in the toolbar")
        XCTAssertTrue(sut.skipButton.exists, "Skip button should render in the toolbar")
    }
    
    func testPlayAndPauseButton_switchCorrectly() {
        launchApp()
        
        XCTAssertTrue(sut.playButton.exists, "Play button should exist initially")
        XCTAssertFalse(sut.pauseButton.exists, "Pause button should not exist initially")
        
        sut.playButton.waitAndTap()
        XCTAssertFalse(sut.playButton.exists, "Play button should no longer exist after pressing play")
        XCTAssertTrue(sut.pauseButton.exists, "Pause button should be visible after pressing play")
        
        sut.pauseButton.waitAndTap()
        XCTAssertTrue(sut.playButton.exists, "Play button should reappear after pausing")
        XCTAssertFalse(sut.pauseButton.exists, "Pause button should no longer exist after pausing")
    }
    
    func testSessionTransitionsAndDefaultDurations() {
        launchApp()
        
        XCTAssertTrue(sut.currentSession.label == "WORK", "Should begin with a work session")
        XCTAssertTrue(sut.remainingTime.label == "25:00", "Work duration should be 25 minutes by default")
        
        sut.skipButton.waitAndTap()
        XCTAssertTrue(sut.currentSession.label == "BREAK", "Should be a short break session after")
        XCTAssertTrue(sut.remainingTime.label == "05:00", "Short break duration should be 5 minutes by default")
        
        // Skip until long break session is reached
        for _ in 1..<7 {
            sut.skipButton.waitAndTap()
        }
        
        XCTAssertTrue(sut.currentSession.label == "L. BREAK", "Should be a long break session after xxx")
        XCTAssertTrue(sut.remainingTime.label == "30:00", "Long break duration should be 30 minutes by default")
    }
    
    func testSessionView_changesWhenSessionIsFinished() {
        launchApp(with: ["-workDuration", "3"])
        
        sut.playButton.waitAndTap()
        XCTAssertTrue(sut.timesUpMessage.waitForExistence(timeout: 5), "Should show 'Times up!' message")
        XCTAssertTrue(sut.completeSessionButton.waitForExistence(timeout: 5), "Should show complete session buton")
    }
}
