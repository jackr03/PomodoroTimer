//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

struct PomodoroView: View {
    private let pomodoroViewModel = PomodoroViewModel.shared
    
    @Bindable private var alertsViewModel = AlertsViewModel.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(pomodoroViewModel.currentSession)
                    .font(.headline.bold())
                    .foregroundStyle(.secondary)
                
                Spacer()
                    
                Text(pomodoroViewModel.formattedRemainingTime)
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                HStack {
                    ForEach(0..<pomodoroViewModel.maxSessions, id: \.self) { number in
                        if number < pomodoroViewModel.currentSessionsDone {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if number == pomodoroViewModel.currentSessionsDone && pomodoroViewModel.isWorkSession {
                            Image(systemName: "circle.dotted.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "circle.dotted")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                Spacer()
                Spacer()
                
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
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
                        }
                        
                        Button(action: {
                            pomodoroViewModel.endCycle()
                            alertsViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "stop.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.resetTimer()
                            alertsViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "arrow.circlepath")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.skipSession()
                            alertsViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "forward.end.fill")
                        }

                    }
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
    PomodoroView()
}
