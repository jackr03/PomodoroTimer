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
        app.launch()
        sut = PomodoroScreen(app: app)
    }

    override func tearDown() {
        app = nil
        sut = nil
        super.tearDown()
    }

    func testActiveSesssionView_rendersProperly() {
        XCTAssertTrue(sut.currentSession.exists, "Current session text should render")
        XCTAssertTrue(sut.sessionProgress.exists, "Session progress text should render")
        XCTAssertTrue(sut.remainingTime.exists, "Remaining time should render")
        XCTAssertTrue(sut.actionButton.exists, "Action button should render")
    }
    
    func testToolbarButtons_renderProperly() {
        XCTAssertTrue(sut.statisticsButton.exists, "Statistics button should render in the toolbar")
        XCTAssertTrue(sut.settingsButton.exists, "Settings button should render in the toolbar")
        XCTAssertTrue(sut.stopButton.exists, "Stop button should render in the toolbar")
        XCTAssertTrue(sut.resetButton.exists, "Reset button should render in the toolbar")
        XCTAssertTrue(sut.skipButton.exists, "Skip button should render in the toolbar")
    }
    
    func testPlayAndPauseButtonSwitchCorrectly() {
        XCTAssertTrue(sut.playButton.exists, "Play button should exist initially")
        XCTAssertFalse(sut.pauseButton.exists, "Pause button should not exist initially")
        
        sut.playButton.tap()
        
        XCTAssertFalse(sut.playButton.exists, "Play button should no longer exist after pressing play")
        XCTAssertTrue(sut.pauseButton.exists, "Pause button should be visible after pressing play")
        
        sut.pauseButton.tap()
        
        XCTAssertTrue(sut.playButton.exists, "Play button should reappear after pausing")
        XCTAssertFalse(sut.pauseButton.exists, "Pause button should no longer exist after pausing")
    }
}
