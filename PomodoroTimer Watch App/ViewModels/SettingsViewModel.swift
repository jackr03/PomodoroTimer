//
//  SettingsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation

final class SettingsViewModel {
    private var pomodoroTimer: PomodoroTimer
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
    }
    
    func updateSettings(_ workDurationInMinutes: Int, _ shortBreakDurationInMinutes: Int, _ longBreakDurationInMinutes: Int) {
        let newWorkDuration = workDurationInMinutes * 60
        let newShortBreakDuration = shortBreakDurationInMinutes * 60
        let newLongBreakDuration = longBreakDurationInMinutes * 60
        
        UserDefaults.standard.set(newWorkDuration, forKey: "workDuration")
        UserDefaults.standard.set(newShortBreakDuration, forKey: "shortBreakDuration")
        UserDefaults.standard.set(newLongBreakDuration, forKey: "longBreakDuration")
        
        updateTimerDurations()
    }
    
    /**
     Update only if the timer isn't currently running.
     */
    private func updateTimerDurations() {
        guard !pomodoroTimer.isTimerTickingStatus else { return }
        
        pomodoroTimer.resetTimer()
    }
}
