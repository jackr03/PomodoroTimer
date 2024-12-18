//
//  TestHelpers.swift
//  PomodoroTimer Watch AppUITests
//
//  Created by Jack Rong on 03/12/2024.
//

import XCTest

extension XCTestCase {
    func waitFor(seconds timeout: TimeInterval) {
        let expectation = XCTestExpectation(description: "Wait \(timeout) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }

    func waitForConditionThenExecute(_ condition: @escaping () -> Bool,
                          action: @escaping () -> Void,
                          timeout: TimeInterval = 3) {
        let expectation = XCTestExpectation(description: "Condition should be true")
        
        let startTime = Date.now
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                action()
                expectation.fulfill()
                break
            }
            
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }
}

extension XCUIElement {
    func waitAndTap(timeout: TimeInterval = 3) {
        XCTAssertTrue(waitForExistence(timeout: timeout), "Could not find element")
        tap()
    }
}

final class Carousel {
    
    // MARK: - Stored properties
    private static let bundleIdentifier = "com.apple.Carousel"
    private static let resumeSessionNotificationLabel = "Stay focused!, Your pomodoro will be paused until you return to the app."
    private static let breakOverNotificationLabel = "Break's over!, Time to get back to work."
    
    private let carousel: XCUIApplication
    
    // MARK: - Inits
    init() {
        self.carousel = XCUIApplication(bundleIdentifier: Self.bundleIdentifier)
    }
    
    // MARK: - Stored properties
    var resumeSessionNotification: XCUIElement { carousel.otherElements[Self.resumeSessionNotificationLabel] }
    var breakOverNotification: XCUIElement { carousel.otherElements[Self.breakOverNotificationLabel] }
    var openAppButton: XCUIElement { carousel.cells["Open app"] }
}
