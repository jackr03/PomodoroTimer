//
//  PomodoroTimerAppUITests.swift
//  PomodoroTimer Watch AppTests
//
//  Created by Jack Rong on 30/11/2024.
//

import XCTest

final class PomodoroTimerAppUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

}
