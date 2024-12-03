//
//  TestHelpers.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 03/12/2024.
//

import XCTest

extension XCUIElement {
    func waitAndTap(timeout: TimeInterval = 3) {
        XCTAssertTrue(waitForExistence(timeout: timeout), "Could not find element")
        tap()
    }
}
