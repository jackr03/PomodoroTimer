//
//  PomodoroTimerApp.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 04/09/2024.
//

import SwiftUI

@main
struct PomodoroTimer_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            let pomodoroTimer: PomodoroTimer = PomodoroTimer(workDuration: 5, breakDuration: 5)
            
            let pomodoroViewModel: PomodoroViewModel = PomodoroViewModel(pomodoroTimer: pomodoroTimer)
            
            return PomodoroView(pomodoroViewModel: pomodoroViewModel)
        }
    }
}
