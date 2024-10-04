//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import SwiftUI

struct CircularProgressBar: View {
    // MARK: - Properties
    private var pomodoroViewModel = PomodoroViewModel.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPulsing = false
    
    // MARK: - Computed properties
    var isScreenInactive: Bool { scenePhase == .inactive }
    var isSessionFinished: Bool { pomodoroViewModel.isSessionFinished }
    var isCentered: Bool { isScreenInactive || pomodoroViewModel.isSessionFinished }
    
    // MARK: - Views
    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width * 0.75
            let maxHeight = geometry.size.height * 0.75
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            ZStack {
                // Progress bar background
                Circle()
                    .stroke(isScreenInactive ? .black : .gray.opacity(0.3), lineWidth: 2)
                
                // Progress bar
                Circle()
                    .trim(from: 0, to: pomodoroViewModel.progress)
                    .stroke(.blue, lineWidth: 2)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: isSessionFinished ? 0.25 : 1), value: pomodoroViewModel.progress)
                
                // Pulsing animation
                if isSessionFinished {
                    Circle()
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                        .onAppear() {
                            startPulsing()
                        }
                        .onDisappear() {
                            stopPulsing()
                        }
                        .scaleEffect(isPulsing ? 1.3 : 1)
                        .opacity(isPulsing ? 0 : 1)
                }

                Button(action: {
                    buttonAction()
                }) {
                    if isSessionFinished {
                        finishedSessionView
                    } else {
                        activeSessionView
                    }
                }
                .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                .clipShape(Circle())
                .buttonStyle(.borderless)
                .handGestureShortcut(.primaryAction)
            }
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .position(x: centerX,
                      y: isCentered ? centerY : (centerY - geometry.size.height * 0.04))
            .animation(.easeInOut, value: isCentered)
        }
    }
    
    var activeSessionView: some View {
        VStack {
            if !isScreenInactive {
                HStack {
                    Text(pomodoroViewModel.currentSession)
                        .font(.caption.bold())
                        .foregroundStyle(Color.secondary)
                        .minimumScaleFactor(0.5)
                    
                    Text("\(pomodoroViewModel.currentSessionsDone)/\(pomodoroViewModel.maxSessions)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.top, 12)
            } else {
                Spacer()
                    .frame(height: 24)
            }
        
            Text(pomodoroViewModel.formattedRemainingTime)
                .font(.title.bold())
                .foregroundStyle(Color.primary)
            
            Image(systemName: pomodoroViewModel.isTimerTicking ? "pause.fill" : "play.fill")
                .foregroundStyle(Color.primary)
                .padding(.top, 6)
        }
    }
    
    var finishedSessionView: some View {
        VStack {
            Spacer()
                .frame(height: 24)
            
            Text("TIME'S UP!")
                .font(.title3.bold())
                .foregroundStyle(.black)
            
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .padding(.top, 18)
        }
    }
    
    // MARK: - Private functions
    private func buttonAction() {
        if isSessionFinished {
            pomodoroViewModel.stopHaptics()
            Haptics.playClick()
        } else {
            if pomodoroViewModel.isTimerTicking {
                pomodoroViewModel.pauseTimer()
                Haptics.playClick()
            } else {
                pomodoroViewModel.startTimer()
                Haptics.playStart()
            }
        }
    }
    
    private func startPulsing() {
        withAnimation(
            Animation.easeIn(duration: 2)
                .repeatForever(autoreverses: false)
        ) {
            isPulsing = true
        }
    }
    
    private func stopPulsing() {
        isPulsing = false
    }
}

struct PomodoroView: View {
    // MARK: - Properties
    @Bindable private var pomodoroViewModel = PomodoroViewModel.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var lastInactiveTime = Date.now
    
    // MARK: - Computed properties
    var isScreenInactive: Bool { scenePhase == .inactive }

    // MARK: - Views
    var body: some View {
        NavigationStack {
            VStack() {
                CircularProgressBar()
            }
            .ignoresSafeArea()
            .toolbar {
                if !isScreenInactive && !pomodoroViewModel.isSessionFinished {
                    toolbarItems()
                }
            }
            .onAppear {
                pomodoroViewModel.refreshDailySessions()
                pomodoroViewModel.checkPermissions()
                pomodoroViewModel.startUpdatingTimeAndProgress(withInterval: 0.5)
            }
            .onChange(of: pomodoroViewModel.isTimerTicking) { _, isTicking in
                isTicking ? pomodoroViewModel.startExtendedSession() : pomodoroViewModel.stopExtendedSession()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handlePhaseChange(oldPhase, newPhase)
            }
            .onChange(of: pomodoroViewModel.isSessionFinished) { _, isFinished in
                if isFinished {
                    pomodoroViewModel.playHaptics()
                }
            }
        }
        .background(pomodoroViewModel.isSessionFinished ? .white : .clear)
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink(destination: StatisticsView()) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.gray)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: SettingsView()) {
                if pomodoroViewModel.isPermissionGranted {
                    Image(systemName: "gear")
                        .foregroundStyle(.gray)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        
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
    
    // MARK: - Private functions
    private func handlePhaseChange(_ oldPhase: ScenePhase, _ newPhase: ScenePhase) {
        // Slow down updates if screen is inactive
        switch (oldPhase, newPhase) {
        case (.inactive, .active):
            pomodoroViewModel.startUpdatingTimeAndProgress(withInterval: 0.5)
        case (.active, .inactive):
            pomodoroViewModel.startUpdatingTimeAndProgress(withInterval: 5)
        default:
            break
        }
        
        guard pomodoroViewModel.isTimerTicking else { return }
        
        switch (oldPhase, newPhase) {
        // If user has left in the middle of a work session, send a notification
        case (.active, .inactive) where pomodoroViewModel.isWorkSession:
            pomodoroViewModel.notifyUserToResume()
        // Record time when user closed app and queue a notification to remind them when break ends
        case (.active, .inactive) where !pomodoroViewModel.isWorkSession:
            lastInactiveTime = Date.now
            pomodoroViewModel.notifyUserWhenBreakOver()
        // Restart the extended session if the user comes back
        case (.background, .inactive) where pomodoroViewModel.isWorkSession:
            pomodoroViewModel.startExtendedSession()
        // Deduct time from the break session and restart the session if there is still time remaining
        // Cancel notification regardless
        case (.background, .inactive) where !pomodoroViewModel.isWorkSession:
            let secondsSinceLastInactive = Int(lastInactiveTime.distance(to: Date.now))
            if pomodoroViewModel.deductBreakTime(by: secondsSinceLastInactive) > 0 {
                pomodoroViewModel.startExtendedSession()
            }
            
            pomodoroViewModel.cancelBreakOverNotification()
        default:
            break
        }
    }
}

 #Preview {
    PomodoroView()
}
