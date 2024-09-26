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
        UserDefaults.standard.set(0, forKey: "totalSessionsCompleted")
        UserDefaults.standard.set(0, forKey: "sessionsCompletedToday")
    }
    
    // TODO: Move functions to HapticsManager
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
}
