//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import SwiftUI

// MARK: - Circular progress bar
struct CircularProgressBar: View {
    // MARK: - Properties
    private let pomodoroViewModel = PomodoroViewModel.shared
    
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Computed properties
    var isInactive: Bool {
        return scenePhase == .inactive
    }
    
    var time: String {
        isInactive ? pomodoroViewModel.formattedRemainingMinutes : pomodoroViewModel.formattedRemainingMinutesAndSeconds
    }
    
    var progress: CGFloat {
        isInactive ? pomodoroViewModel.progressRounded : pomodoroViewModel.progress
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 7)
                
                Button(action: {
                    if pomodoroViewModel.isTimerTicking {
                        pomodoroViewModel.pauseTimer()
                        Haptics.playClick()
                    } else {
                        pomodoroViewModel.startTimer()
                        Haptics.playStart()
                    }
                }) {
                    VStack(alignment: .center) {
                        HStack {
                            Text(pomodoroViewModel.currentSession)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.secondary)
                            
                            Text("\(pomodoroViewModel.currentSessionsDone)/\(pomodoroViewModel.maxSessions)")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                            
                            
                                // TODO: Reimplement this
//                            HStack {
//                                ForEach(0..<pomodoroViewModel.maxSessions, id: \.self) { number in
//                                    if number < pomodoroViewModel.currentSessionsDone {
//                                        Image(systemName: "circle.fill")
//                                            .font(.caption)
//                                            .foregroundStyle(.secondary)
//                                    } else if number == pomodoroViewModel.currentSessionsDone && pomodoroViewModel.isWorkSession {
//                                        Image(systemName: "circle.dotted.circle")
//                                            .font(.caption)
//                                            .foregroundStyle(.secondary)
//                                    } else {
//                                        Image(systemName: "circle.dotted")
//                                            .font(.caption)
//                                            .foregroundStyle(.secondary)
//                                    }
//                                }
//                            }
                        }
                        .padding(.top, 6)
                        
                        Text(time)
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color.primary)
                        
                        Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                            .foregroundStyle(Color.primary)
                            .padding(.top, 6)
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.75,
                       maxHeight: geometry.size.height * 0.75)
                .clipShape(Circle())
                .buttonStyle(.borderless)
                .handGestureShortcut(.primaryAction)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, lineWidth: 7)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)
            }
            .frame(maxWidth: geometry.size.width * 0.75,
                   maxHeight: geometry.size.height * 0.75)
            .clipShape(Circle())
            .position(x: geometry.size.width / 2,
                      y: geometry.size.height / 2 - geometry.size.height * 0.04)
        }
    }
}

// MARK: - Main struct
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
            VStack() {
                CircularProgressBar()
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: StatisticsView()) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        if pomodoroViewModel.permissionsGranted {
                            Image(systemName: "gear")
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                // TODO: Improve the UI for buttons
                ToolbarItemGroup(placement: .bottomBar) {
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
            .onAppear {
                pomodoroViewModel.refreshDailySessions()
                pomodoroViewModel.checkPermissions()
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
                    pomodoroViewModel.deductBreakTime(by: secondsSinceLastInactive)
                    pomodoroViewModel.cancelBreakOverNotification()
                    // Store time when app went inactive and queue a notification
                } else if oldScene == .active && newScene == .inactive && pomodoroViewModel.isTimerTicking && !pomodoroViewModel.isWorkSession {
                    lastInactiveTime = Date.now
                    pomodoroViewModel.notifyUserWhenBreakOver()
                }
            }
            .onChange(of: pomodoroViewModel.showingFinishedAlert) { _, isFinished in
                if isFinished {
                    pomodoroViewModel.playHaptics()
                }
            }
            .alert("Time's up!", isPresented: $pomodoroViewModel.showingFinishedAlert) {
                Button("OK") {
                    pomodoroViewModel.completeSession()
                    pomodoroViewModel.stopHaptics()
                }
            }
        }
    }
}

 #Preview {
    PomodoroView()
}
