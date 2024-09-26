//
//  StatisticsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import WatchKit

final class StatisticsViewModel {
    // MARK: - Properties
    static let shared = StatisticsViewModel()
    
    private init() {}
    
    // MARK: - Functions
    func resetSessions() {
        Defaults.set("sessionsCompletedToday", to: 0)
        Defaults.set("totalSessionsCompleted", to: 0)
    }
}
