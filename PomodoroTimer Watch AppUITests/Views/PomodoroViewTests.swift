//
//  PomodoroViewTests.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest

final class PomodoroViewTests: XCTestCase {
        
    private var app: XCUIApplication!
    private var pomodoroScreen: PomodoroScreen!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        pomodoroScreen = PomodoroScreen(app: app)
    }

    override func tearDown() {
        app = nil
        pomodoroScreen = nil
        super.tearDown()
    }

    func testToolbarButtons_renderProperly() {
        XCTAssertTrue(pomodoroScreen.statisticsButton.exists, "Statistics button should render in the toolbar")
        XCTAssertTrue(pomodoroScreen.settingsButton.exists, "Settings button should render in the toolbar")
        XCTAssertTrue(pomodoroScreen.stopButton.exists, "Stop button should render in the toolbar")
        XCTAssertTrue(pomodoroScreen.resetButton.exists, "Reset button should render in the toolbar")
        XCTAssertTrue(pomodoroScreen.skipButton.exists, "Skip button should render in the toolbar")
    }
    
    func testPlayButtonOnly_rendersInitially() {
        XCTAssertTrue(pomodoroScreen.playButton.exists, "Play button should render initially")
        XCTAssertFalse(pomodoroScreen.pauseButton.exists, "Pause button should not render initially")
    }
    
    func testPauseButton_rendersAfterPressingPlay() {
        pomodoroScreen.playButton.tap()
        XCTAssertTrue(pomodoroScreen.pauseButton.exists, "Pause button should render after pressing play")
    }
}
