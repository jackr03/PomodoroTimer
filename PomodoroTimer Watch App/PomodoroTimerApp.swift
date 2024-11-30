//
//  PomodoroTimerApp.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 04/09/2024.
//

import SwiftUI

@main
struct PomodoroTimer_Watch_AppApp: App {
    
    private let coordinator = NavigationCoordinator()
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: coordinator)
        }
    }
}
