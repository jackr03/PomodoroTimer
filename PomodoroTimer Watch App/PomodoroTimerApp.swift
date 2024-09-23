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
        // For testing purposes
//        UserDefaults.standard.set(3, forKey:"workDuration")
//        UserDefaults.standard.set(3, forKey:"longBreakDuration")
//        UserDefaults.standard.set(3, forKey:"shortBreakDuration")
    }
    
    var body: some Scene {
        WindowGroup {
            PomodoroView()
        }
    }
}
