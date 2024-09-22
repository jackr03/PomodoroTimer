//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

struct PomodoroView: View {
    @Bindable private var pomodoroViewModel = PomodoroViewModel.shared
    
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
                Spacer()
                Spacer()
                
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: {
                            if pomodoroViewModel.isTimerTicking {
                                pomodoroViewModel.pauseTimer()
                                pomodoroViewModel.playPressedHaptic()
                            } else {
                                pomodoroViewModel.startTimer()
                                pomodoroViewModel.playStartHaptic()
                            }
                        }) {
                            Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.endCycle()
                            pomodoroViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "stop.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.resetTimer()
                            pomodoroViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "arrow.circlepath")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.skipSession()
                            pomodoroViewModel.playPressedHaptic()
                        }) {
                            Image(systemName: "forward.end.fill")
                        }

                    }
                }

            }
        }
        .onChange(of: pomodoroViewModel.showFinishedAlert) { _, newValue in
            if newValue {
                pomodoroViewModel.playHaptics()
            }
        }
        .alert("Time's up!", isPresented: $pomodoroViewModel.showFinishedAlert) {
            Button("OK") {
                pomodoroViewModel.stopHaptics()
            }
        }
    }
}

 #Preview {
    PomodoroView()
}
