//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import WatchKit

final class SettingsViewModel {
    static let shared = SettingsViewModel()
    
    private let pomodoroTimer = PomodoroTimer.shared
    
    private init() {}
    
    func updateSetting(to value: Int, forKey key: String) {
        // Convert time back to seconds
        let valueInSeconds = value * 60
        UserDefaults.standard.set(valueInSeconds, forKey: key)
        
        updateTimer()
    }
    
    func resetSettings() {
        UserDefaults.standard.set(1500, forKey: "workDuration")
        UserDefaults.standard.set(300, forKey: "shortBreakDuration")
        UserDefaults.standard.set(1800, forKey: "longBreakDuration")
        
        updateTimer()
    }
    
    /**
     Update only if the timer isn't currently running.
     */
    private func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
    
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
}
