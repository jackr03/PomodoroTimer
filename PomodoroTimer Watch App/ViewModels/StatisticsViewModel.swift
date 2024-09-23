//
//  StatisticsViewModel.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import WatchKit

final class StatisticsViewModel {
    static let shared = StatisticsViewModel()
    
    private init() {}
    
    func resetSessions() {
        UserDefaults.standard.set(0, forKey: "sessionsCompleted")
    }
    
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
}
