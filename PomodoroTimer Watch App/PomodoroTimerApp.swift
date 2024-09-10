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
            TabView {
                PomodoroView()
                    .tabItem {
                        Label("Pomodoro", systemImage: "clock")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
