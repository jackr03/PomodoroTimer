//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

struct PomodoroView: View {
    @Bindable private var alertsViewModel = AlertsViewModel.shared
    private var pomodoroViewModel: PomodoroViewModel
    
    init(_ pomodoroViewModel: PomodoroViewModel) {
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
                    if pomodoroViewModel.isTimerTicking {
                        pomodoroViewModel.pauseTimer()
                        alertsViewModel.playPressedHaptic()
                    } else {
                        pomodoroViewModel.startTimer()
                        alertsViewModel.playStartHaptic()
                    }
                }) {
                    Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                
                Button(action: {
                    pomodoroViewModel.endCycle()
                    alertsViewModel.playPressedHaptic()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Button(action: {
                    pomodoroViewModel.resetTimer()
                    alertsViewModel.playPressedHaptic()
                }) {
                    Image(systemName: "arrow.circlepath")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Button(action: {
                    pomodoroViewModel.skipSession()
                    alertsViewModel.playPressedHaptic()
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: alertsViewModel.showAlert) { _, newValue in
            if newValue {
                alertsViewModel.playHaptics()
            }
        }
        .alert("Time's up!", isPresented: $alertsViewModel.showAlert) {
            Button("OK") {
                alertsViewModel.stopHaptics()
            }
        }
    }
}

 #Preview {
    PomodoroView(PomodoroViewModel())
}
