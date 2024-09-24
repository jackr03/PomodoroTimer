//
//  PomodoroTimerApp.swift
//  PomodoroTimer Mac App
//
//  Created by Jack Rong on 23/09/2024.
//

import SwiftUI

@main
struct PomodoroTimer_Mac_App: App {
    @State private var currentNumber: String = "1"
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            
            Button("Two") {
                currentNumber = "2"
            }
            
            Button("Three") {
                currentNumber = "3"
            }
        }
    }
}
