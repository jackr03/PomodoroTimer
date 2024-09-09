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
    @State private var pomodoroViewModel: PomodoroViewModel
    
    @State private var showFinishedAlert = false
    @State private var hapticTimer: Timer? = nil
    
    init(pomodoroViewModel: PomodoroViewModel) {
        self.pomodoroViewModel = pomodoroViewModel
    }
    
    var body: some View {
        VStack {
            Text(pomodoroViewModel.currentSession)
            
            Text(pomodoroViewModel.formattedRemainingTime)
                .font(.largeTitle)
            
            Spacer()
            
            HStack {
                Button(action: {
                    pomodoroViewModel.isActive ? pomodoroViewModel.pauseTimer() : pomodoroViewModel.startTimer()
                }) {
                    Image(systemName: pomodoroViewModel.isActive ? "pause.fill" : "play.fill")
                }

                Button(action: {
                    pomodoroViewModel.stopTimer()
                }) {
                    Image(systemName: "stop.fill")
                }
            }
        }
        .onChange(of: pomodoroViewModel.isTimerFinished) { _, newValue in
            if newValue {
                startHapticTimer()
                showFinishedAlert = true
            }
        }
        .alert("Timer finished", isPresented: $showFinishedAlert) {
            Button("OK") {
                pomodoroViewModel.stopTimer()
                stopHapticTimer()
            }
        }
    }
    
    func startHapticTimer() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

#Preview {
    let pomodoroTimer: PomodoroTimer = PomodoroTimer(workDuration: 5, breakDuration: 5)
    
    let pomodoroViewModel: PomodoroViewModel = PomodoroViewModel(pomodoroTimer: pomodoroTimer)
    
    return PomodoroView(pomodoroViewModel: pomodoroViewModel)
}
