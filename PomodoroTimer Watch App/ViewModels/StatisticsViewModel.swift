//
//  StatisticsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class StatisticsViewModel {
    // MARK: - Properties
    static let shared = StatisticsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    
    // MARK: - Init
    private init() {}
    
    var isSessionFinished: Bool {
        return pomodoroTimer.isSessionFinished
    }
    
    // MARK: - Functions
    func resetSessions() {
        Defaults.set("sessionsCompletedToday", to: 0)
        Defaults.set("totalSessionsCompleted", to: 0)
    }
}
