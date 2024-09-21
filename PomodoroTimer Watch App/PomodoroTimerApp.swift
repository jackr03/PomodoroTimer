//
//  PomodoroTimerApp.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 04/09/2024.
//

import Foundation
import SwiftUI

@main
struct PomodoroTimer_Watch_AppApp: App {
    private var pomodoroViewModel: PomodoroViewModel
    private var settingsViewModel: SettingsViewModel
    
    init() {
        UserDefaults.standard.set(5, forKey: "workDuration")
        self.pomodoroViewModel = PomodoroViewModel()
        self.settingsViewModel = SettingsViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PomodoroView(pomodoroViewModel)
                    .tabItem {
                        Label("Pomodoro", systemImage: "clock")
                    }
                
                SettingsView(settingsViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
