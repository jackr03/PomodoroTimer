//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI
import Observation

struct PomodoroView: View {
    private var pomodoroViewModel: PomodoroViewModel
    
    @State private var showFinishedAlert = false
    @State private var hapticTimer: Timer? = nil
    
    init(pomodoroViewModel: PomodoroViewModel) {
        self.pomodoroViewModel = pomodoroViewModel
    }
    
    var body: some View {
        VStack {
            Text(pomodoroViewModel.currentSession)
                .font(.headline)
            
            Text(pomodoroViewModel.formattedRemainingTime)
                .font(.system(size: 50))
            
            Spacer()
            
            HStack {
                Button(action: {
                    pomodoroViewModel.isActive ? pomodoroViewModel.pauseTimer() : pomodoroViewModel.startTimer()
                }) {
                    Image(systemName: pomodoroViewModel.isActive ? "pause.fill" : "play.fill")
                        .font(.body)
                }

                Button(action: {
                    pomodoroViewModel.stopTimer()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.body)
                }
            }
        }
        .onChange(of: pomodoroViewModel.isTimerFinished) { _, newValue in
            if newValue {
                startHaptics()
                showFinishedAlert = true
            }
        }
        .alert("Timer finished", isPresented: $showFinishedAlert) {
            Button("OK") {
                stopHaptics()
            }
        }
    }
    
    func startHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            WKInterfaceDevice.current().play(.stop)
        }
    }
    
    func stopHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

#Preview {
    let pomodoroTimer: PomodoroTimer = PomodoroTimer(workDuration: 3, breakDuration: 5)
    
    let pomodoroViewModel: PomodoroViewModel = PomodoroViewModel(pomodoroTimer: pomodoroTimer)
    
    return PomodoroView(pomodoroViewModel: pomodoroViewModel)
}
