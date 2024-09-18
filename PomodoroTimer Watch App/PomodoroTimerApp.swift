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
    private var pomodoroTimer: PomodoroTimer
    private var pomodoroViewModel: PomodoroViewModel
    private var settingsViewModel: SettingsViewModel
    
    init() {
        // For testing
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        for key in dictionary.keys {
//            defaults.removeObject(forKey: key)
//        }
        
        self.pomodoroTimer = PomodoroTimer()
        self.pomodoroViewModel = PomodoroViewModel(pomodoroTimer: pomodoroTimer)
        self.settingsViewModel = SettingsViewModel(pomodoroTimer: pomodoroTimer)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PomodoroView(pomodoroViewModel: pomodoroViewModel)
                    .tabItem {
                        Label("Pomodoro", systemImage: "clock")
                    }
                
                SettingsView(settingsViewModel: settingsViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
