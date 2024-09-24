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
    
    @Environment(\.scenePhase) private var scenePhase

    var isActive: Bool {
        return scenePhase == .active
    }
    
    var isInactive: Bool {
        return scenePhase == .inactive
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(pomodoroViewModel.currentSession)
                    .font(.headline.bold())
                    .foregroundStyle(.secondary)
                
                Spacer()
                    
                Text(isInactive ? pomodoroViewModel.formattedRemainingMinutes : pomodoroViewModel.formattedRemainingMinutesAndSeconds)
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
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: StatisticsView()) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: {
                            if pomodoroViewModel.isTimerTicking {
                                pomodoroViewModel.pauseTimer()
                                pomodoroViewModel.playClickHaptic()
                            } else {
                                pomodoroViewModel.startTimer()
                                pomodoroViewModel.playStartHaptic()
                            }
                        }) {
                            Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.endCycle()
                            pomodoroViewModel.playClickHaptic()
                        }) {
                            Image(systemName: "stop.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.resetTimer()
                            pomodoroViewModel.playClickHaptic()
                        }) {
                            Image(systemName: "arrow.circlepath")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.skipSession()
                            pomodoroViewModel.playClickHaptic()
                        }) {
                            Image(systemName: "forward.end.fill")
                        }
                    }
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                pomodoroViewModel.updateDailySessionsIfNeeded()
            }
        }
        .onChange(of: pomodoroViewModel.showingFinishedAlert) { _, newValue in
            if newValue {
                pomodoroViewModel.playHaptics()
            }
        }
        .alert("Time's up!", isPresented: $pomodoroViewModel.showingFinishedAlert) {
            Button("OK") {
                pomodoroViewModel.stopHaptics()
            }
        }
    }
}

 #Preview {
    PomodoroView()
}
