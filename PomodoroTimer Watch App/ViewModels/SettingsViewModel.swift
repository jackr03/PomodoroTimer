//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation

final class SettingsViewModel {
    private var pomodoroTimer = PomodoroTimer.shared
    
    func updateSetting(to value: Int, forKey key: String) {
        // Convert time back to seconds
        let valueInSeconds = value * 60
        UserDefaults.standard.set(valueInSeconds, forKey: key)
        
        updateTimer()
    }
    
    /**
     Update only if the timer isn't currently running.
     */
    private func updateTimer() {
        guard !pomodoroTimer.isTimerTicking else { return }
        
        pomodoroTimer.resetTimer()
    }
}
