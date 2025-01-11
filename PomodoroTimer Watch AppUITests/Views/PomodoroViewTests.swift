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

    func testView_rendersProperly() {
        launchApp()
        
        XCTAssertTrue(sut.currentSession.exists, "Current session text should render")
        XCTAssertTrue(sut.sessionProgress.exists, "Session progress text should render")
        XCTAssertTrue(sut.remainingTime.exists, "Remaining time should render")
        XCTAssertTrue(sut.actionButton.exists, "Action button should render")
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
    
    func testStatisticsButton_navigatesToCorrectScreen() {
        launchApp()
        let statisticsScreen = StatisticsScreen(app: app)
        
        sut.statisticsButton.waitAndTap()
        XCTAssertTrue(statisticsScreen.dailyTitle.waitForExistence(timeout: 3))
    }
    
    func testSettingsButton_navigatesToSettingsScreen() {
        launchApp()
        let settingsScreen = SettingsScreen(app: app)
        
        sut.settingsButton.waitAndTap()
        XCTAssertTrue(settingsScreen.navigationBarTitle.waitForExistence(timeout: 3))
    }
    
    func testSkipButton_skipsSession() {
        launchApp()
        
        sut.skipButton.waitAndTap()
        XCTAssertTrue(sut.currentSession.label == "BREAK", "Should skip to break session")
    }
    
    func testSessionView_changesWhenSessionIsFinished() {
        launchApp(with: ["-workDuration", "3"])
        
        sut.playButton.waitAndTap()
        XCTAssertTrue(sut.timesUpMessage.waitForExistence(timeout: 5), "Should show 'Times up!' message")
        XCTAssertTrue(sut.completeSessionButton.waitForExistence(timeout: 5), "Should show complete session buton")
    }
    
    func testWorkNotification_isShownWhenLeavingActiveWorkSession() {
        launchApp()
        let carousel = Carousel()
        
        sut.playButton.waitAndTap()
        waitForConditionThenExecute({
            self.sut.remainingTime.label == "24:59"
        }) {
            XCUIDevice.shared.press(.home)
        }
        XCTAssertTrue(carousel.resumeSessionNotification.waitForExistence(timeout: 5), "Should show notification prompting user to return to app")
    }
    
    func testWorkNotification_isNotShownWhenLeavingPausedWorkSession() {
        launchApp()
        let carousel = Carousel()
        
        sut.playButton.waitAndTap()
        sut.pauseButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertFalse(carousel.resumeSessionNotification.waitForExistence(timeout: 5), "Should not show notification prompting user to return to app")
    }
    
    func testWorkNotification_isNotShownWhenLeavingBreakSession() {
        launchApp()
        let carousel = Carousel()
        
        sut.skipButton.waitAndTap()
        sut.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertFalse(carousel.resumeSessionNotification.waitForExistence(timeout: 5), "Should not show notification prompting user to return to app")
    }
    
    func testBreakNotification_isShownWhenBreakEnds() {
        launchApp(with: ["-shortBreakDuration", "3"])
        let carousel = Carousel()
        
        sut.skipButton.waitAndTap()
        sut.playButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(carousel.breakOverNotification.waitForExistence(timeout: 10), "Should show notification letting user know session is over")
    }
    
    func testBreakOverNotification_isNotQueuedIfPaused() {
        launchApp(with: ["-shortBreakDuration", "3"])
        let carousel = Carousel()
        
        sut.skipButton.waitAndTap()
        sut.playButton.waitAndTap()
        sut.pauseButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCTAssertFalse(carousel.breakOverNotification.waitForExistence(timeout: 5), "Should not show notification letting user know session is over")
    }
    
    func testTimerDoesNotGoDown_whenLeavingAnActiveWorkSession() {
        launchApp()
        let carousel = Carousel()

        sut.playButton.waitAndTap()
        waitForConditionThenExecute({
            self.sut.remainingTime.label == "24:59"
        }) {
            XCUIDevice.shared.press(.home)
        }
        carousel.openAppButton.waitAndTap(timeout: 5)
        XCTAssertTrue(sut.remainingTime.label == "24:59", "Timer should not have continued counting down")
    }
    
    func testTimerAutoPlays_whenReopeningAnActiveWorkSession() {
        launchApp()
        let carousel = Carousel()
        
        sut.playButton.waitAndTap()
        waitForConditionThenExecute({
            self.sut.remainingTime.label == "24:59"
        }) {
            XCUIDevice.shared.press(.home)
        }
        
        carousel.openAppButton.waitAndTap(timeout: 5)
        XCTAssertTrue(sut.pauseButton.exists, "Timer should continue playing")
    }
    
    func testTimerDoesNotAutoPlay_whenReopeningAPausedWorkSession() {
        launchApp()
        
        sut.playButton.waitAndTap()
        sut.pauseButton.waitAndTap()
        XCUIDevice.shared.press(.home)
        XCUIApplication().activate()
        XCTAssertTrue(sut.playButton.exists, "Timer should remain paused")
    }
    
    func testTimer_continuesCountingDown_whenLeavingBreakSession() {
        launchApp()
        
        sut.skipButton.waitAndTap()
        sut.playButton.waitAndTap()
        waitForConditionThenExecute({
            self.sut.remainingTime.label == "04:59"
        }) {
            XCUIDevice.shared.press(.home)
        }
        
        // Allow timer to tick down
        waitFor(seconds: 3)
        XCUIApplication().activate()
        
        // Allow time to update
        waitFor(seconds: 1)
        XCTAssertFalse(sut.remainingTime.label == "04:59", "Timer should have continued counting down")
        XCTAssertTrue(sut.pauseButton.exists, "Timer should continue playing")
    }
}
