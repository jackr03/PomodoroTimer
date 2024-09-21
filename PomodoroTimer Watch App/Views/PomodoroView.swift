//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

struct PomodoroView: View {
    @State private var showFinishedAlert = false

    private var pomodoroViewModel: PomodoroViewModel
        
    init(pomodoroViewModel: PomodoroViewModel) {
        self.pomodoroViewModel = pomodoroViewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(pomodoroViewModel.currentSession)
                    .font(.headline)
                
                HStack {
                    ForEach(0..<pomodoroViewModel.maxSessions, id: \.self) { number in
                        if number < pomodoroViewModel.currentSessionsDone {
                            Image(systemName: "circle.fill")
                                .font(.subheadline)
                        } else if number == pomodoroViewModel.currentSessionsDone && pomodoroViewModel.isWorkSession {
                            Image(systemName: "circle.dotted.circle")
                                .font(.subheadline)
                        } else {
                            Image(systemName: "circle.dotted")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            Text(pomodoroViewModel.formattedRemainingTime)
                .font(.system(size: 60))
            
            Spacer()
            
            HStack {
                Button(action: {
                    pomodoroViewModel.isTimerTicking ? pomodoroViewModel.pauseTimer() : pomodoroViewModel.startTimer()
                }) {
                    Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                        .font(.body)
                }
                
                Button(action: {
                    pomodoroViewModel.stopTimer()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.body)
                }
                
                Button(action: {
                    pomodoroViewModel.resetTimer()
                }) {
                    Image(systemName: "arrow.circlepath")
                        .font(.body)
                }
            }
        }
        .onChange(of: pomodoroViewModel.isTimerFinished) { _, newValue in
            if newValue {
                pomodoroViewModel.endSession()
                showFinishedAlert = true
            }
        }
        .alert("Time's up!", isPresented: $showFinishedAlert) {
            Button("OK") {
                pomodoroViewModel.stopHaptics()
            }
        }
    }
}

 #Preview {
    let pomodoroTimer = PomodoroTimer()
    let pomodoroViewModel = PomodoroViewModel(pomodoroTimer: pomodoroTimer)
    
    PomodoroView(pomodoroViewModel: pomodoroViewModel)
}
