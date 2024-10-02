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
    init() {
        Defaults.set("workDuration", to: 3)
        Defaults.set("shortBreakDuration", to: 3)
    }
    
    var body: some Scene {
        WindowGroup {
            PomodoroView()
        }
    }
}
