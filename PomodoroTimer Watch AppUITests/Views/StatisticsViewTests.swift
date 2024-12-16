//
//  StatisticsViewTests.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 16/12/2024.
//

import XCTest

final class StatisticsViewTests: XCTestCase {

    private var app: XCUIApplication!
    private var sut: StatisticsScreen!

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
        sut = StatisticsScreen(app: app)
        PomodoroScreen(app: app).statisticsButton.waitAndTap()
        XCTAssertTrue(sut.dailyTitle.waitForExistence(timeout: 3),
                      "Statistics screen should be visible within 3 seconds")
    }

    func testView_rendersProperly() {
        launchApp()
        
        XCTAssertTrue(sut.dailyTitle.exists, "Should be on daily view")
        XCTAssertTrue(sut.dailyProgressBar.exists, "Daily progress bar should render")
        XCTAssertTrue(sut.dailySessionsCompleted.exists, "Daily sessions completed should render")
        XCTAssertTrue(sut.dailyTimeSpent.exists, "Daily time spent should render")
        XCTAssertTrue(sut.dailyStatusMessage.exists, "Daily status message should render")
        
        app.swipeUp()
        XCTAssertTrue(sut.weeklyTitle.exists, "Should be on weekly view")
        XCTAssertTrue(sut.weeklyChart.exists, "Weekly chart should render")
        
        app.swipeUp()
        XCTAssertTrue(sut.monthlyTitle.exists, "Should be on monthly view")
        XCTAssertTrue(sut.monthlyChart.exists, "Monthly chart should render")
        
        app.swipeUp()
        XCTAssertTrue(sut.allTimeTitle.exists, "Should be on all time view")
        XCTAssertTrue(sut.allTimeSummary.exists, "All time summary should render")
        
        app.swipeUp()
        XCTAssertTrue(sut.deleteAllRecordsButton.exists, "Delete all records button should render")
    }
}
