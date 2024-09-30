//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

struct PomodoroView: View {
    // MARK: - Properties
    @Bindable private var pomodoroViewModel = PomodoroViewModel.shared
    
    @State private var lastInactiveTime = Date.now

    @Environment(\.scenePhase) private var scenePhase    

    // MARK: - Computed properties
    var isInactive: Bool {
        return scenePhase == .inactive
    }
    
    // MARK: - Body
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
                                Haptics.playClick()
                            } else {
                                pomodoroViewModel.startTimer()
                                Haptics.playStart()
                            }
                        }) {
                            Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.endCycle()
                            Haptics.playClick()
                        }) {
                            Image(systemName: "stop.fill")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.resetTimer()
                            Haptics.playClick()
                        }) {
                            Image(systemName: "arrow.circlepath")
                        }
                        
                        Button(action: {
                            pomodoroViewModel.skipSession()
                            Haptics.playClick()
                        }) {
                            Image(systemName: "forward.end.fill")
                        }
                    }
                }
            }
        }
        .onAppear {
            pomodoroViewModel.refreshDailySessions()
        }
        .onChange(of: pomodoroViewModel.isTimerTicking) { _, isTicking in
            if isTicking {
                pomodoroViewModel.startExtendedSession()
            } else {
                pomodoroViewModel.stopExtendedSession()
            }
        }
        // TODO: Clean this up
        .onChange(of: scenePhase) { oldScene, newScene in
            // Send notification for the user to reopen the app
            if oldScene == .active && newScene == .inactive && pomodoroViewModel.isTimerTicking && pomodoroViewModel.isWorkSession {
                pomodoroViewModel.notifyUserToResume()
            // Resume session if user reopens app
            } else if newScene == .inactive && pomodoroViewModel.isTimerTicking && pomodoroViewModel.isWorkSession && !pomodoroViewModel.isExtendedSessionRunning {
                pomodoroViewModel.startExtendedSession()
            // Deduct break time by how much time has passed since user closed app
            } else if oldScene == .background && newScene == .inactive && pomodoroViewModel.isTimerTicking && !pomodoroViewModel.isWorkSession && !pomodoroViewModel.isExtendedSessionRunning {
                pomodoroViewModel.startExtendedSession()
                let secondsSinceLastInactive = Int(lastInactiveTime.distance(to: Date.now))
                pomodoroViewModel.deductTime(by: secondsSinceLastInactive)
            // Store time when app went inactive
            } else if oldScene == .active && newScene == .inactive && pomodoroViewModel.isTimerTicking && !pomodoroViewModel.isWorkSession {
                lastInactiveTime = Date.now
            }
        }
        .onChange(of: pomodoroViewModel.showingFinishedAlert) { _, isFinished in
            if isFinished {
                pomodoroViewModel.playHaptics()
            }
        }
        .alert("Time's up!", isPresented: $pomodoroViewModel.showingFinishedAlert) {
            Button("OK") {
                pomodoroViewModel.nextSession()
                pomodoroViewModel.stopHaptics()
            }
        }
    }
}

 #Preview {
    PomodoroView()
}
