//
//  TestHelpers.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 03/12/2024.
//

import XCTest

extension XCUIElement {
    func waitAndTap() {
        XCTAssertTrue(waitForExistence(timeout: 3))
        tap()
    }
}
