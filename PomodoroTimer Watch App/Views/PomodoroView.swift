//
//  PomodoroView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 08/09/2024.
//

import SwiftUI

struct PomodoroView: View {
    
    // MARK: - Stored properties
    private let hapticsManager = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var viewModel: PomodoroViewModel
    @State private var lastInactiveTime = Date.now
    @State private var isPulsing = false
    @State private var hapticTimer: Timer?
    
    // MARK: - Inits
    init(viewModel: PomodoroViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Computed properties
    var isScreenInactive: Bool { scenePhase == .inactive }
    var isSessionFinished: Bool { viewModel.isSessionFinished }
    var isCentered: Bool { isScreenInactive || isSessionFinished }
    
    var time: String {
        isScreenInactive ? viewModel.cachedFormattedRemainingTime : viewModel.formattedRemainingTime
    }
    
    var progress: CGFloat {
        isScreenInactive ? viewModel.cachedProgress : viewModel.progress
    }

    // MARK: - Views
    var body: some View {
        @Bindable var coordinator = coordinator
        
        VStack() {
            circularProgressBar
        }
        .ignoresSafeArea()
        .background(isSessionFinished ? .white : .clear)
        .toolbar {
            if !isScreenInactive && !isSessionFinished {
                toolbarItems()
            }
        }
        .onChange(of: isSessionFinished) { _, isFinished in
            if isFinished {
                coordinator.popToRoot()
                playHaptics()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handlePhaseChange(oldPhase, newPhase)
        }
    }
    
    // MARK: - Private functions
    private func handlePhaseChange(_ oldPhase: ScenePhase, _ newPhase: ScenePhase) {
        // Slow down updates if screen is inactive
        switch (oldPhase, newPhase) {
        case (.inactive, .active):
            viewModel.stopCachingTimeAndProgress()
        case (.active, .inactive):
            viewModel.startCachingTimeAndProgress()
        case (.background, .inactive):
            viewModel.clearNotifications()
        default:
            break
        }
        
        guard viewModel.isTimerActive || viewModel.hasSessionStarted else { return }
        
        switch (oldPhase, newPhase) {
        // If user has left in the middle of a work session, pause timer and send a notification
        case (.inactive, .background) where viewModel.isTimerActive && viewModel.hasSessionStarted:
            viewModel.pauseSession()
            viewModel.notifyUserToResume()
        // Record time when user closed app and queue a notification to remind them when break ends
        case (.active, .inactive) where !viewModel.isWorkSession:
            lastInactiveTime = Date.now
            viewModel.notifyUserWhenBreakOver()
        // Restart the extended session if the user comes back
        case (.background, .inactive) where viewModel.isWorkSession && viewModel.hasSessionStarted:
            viewModel.startSession()
        // Deduct time from the break session and restart the session if there is still time remaining
        case (.background, .inactive) where !viewModel.isWorkSession:
            let secondsSinceLastInactive = Int(lastInactiveTime.distance(to: Date.now))
            if viewModel.deductBreakTime(by: secondsSinceLastInactive) > 0 {
                viewModel.startExtendedSession()
            }
        default:
            break
        }
    }
    
    private func buttonAction() async {
        if isSessionFinished {
            stopHaptics()
            viewModel.completeSession()
            hapticsManager.playClick()
            
            return
        }
        
        if viewModel.isTimerActive {
            viewModel.pauseSession()
            hapticsManager.playClick()
        } else {
            viewModel.startSession()
            hapticsManager.playStart()
        }
    }
    
    private func playHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            hapticsManager.playStop()
        }
    }

    private func stopHaptics() {
        if let hapticTimer = hapticTimer {
            hapticTimer.invalidate()
            self.hapticTimer = nil
        }
    }
}

private extension PomodoroView {
    var circularProgressBar: some View {
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
                    .trim(from: 0, to: progress)
                    .stroke(.blue, lineWidth: 2)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: isSessionFinished ? 0.25 : 1), value: progress)
                
                // Pulsing animation
                if isSessionFinished && !isScreenInactive {
                    Circle()
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                        .scaleEffect(isPulsing ? 1.3 : 1)
                        .opacity(isPulsing ? 0 : 1)
                        .animation(
                            .easeIn(duration: 2)
                            .repeatForever(autoreverses: false),
                            value: isPulsing)
                        .onAppear() {
                            isPulsing = true
                        }
                        .onDisappear() {
                            isPulsing = false
                        }
                }
                
                Button(action: {
                    Task {
                        await buttonAction()
                    }
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
                .accessibilityIdentifier("actionButton")
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
                    Text(viewModel.currentSession)
                        .font(.caption.bold())
                        .foregroundStyle(Color.secondary)
                        .minimumScaleFactor(0.5)
                        .accessibilityIdentifier("currentSession")
                    
                    Text(viewModel.sessionProgress)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .accessibilityIdentifier("sessionProgress")
                }
                .padding(.top, 12)
            } else {
                Spacer()
                    .frame(height: 24)
            }
            
            Text(time)
                .font(.title.bold())
                .foregroundStyle(Color.primary)
                .accessibilityIdentifier("remainingTime")
            
            Image(systemName: viewModel.isTimerActive ? "pause.fill" : "play.fill")
                .foregroundStyle(Color.primary)
                .padding(.top, 6)
                .accessibilityIdentifier(viewModel.isTimerActive ? "pauseButton" : "playButton")
        }
    }
    
    var finishedSessionView: some View {
        VStack {
            Spacer()
                .frame(height: 24)
                .padding(.top, 12)
            
            Text("TIME'S UP!")
                .font(.title3.bold())
                .foregroundStyle(.black)
                .accessibilityIdentifier("timesUpMessage")
            
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .padding(.top, 18)
                .accessibilityIdentifier("completeSessionButton")
        }
    }
    
    @ToolbarContentBuilder
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                coordinator.push(.statistics)
            }) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.gray)
            }
            .accessibilityIdentifier("statisticsButton")
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                coordinator.push(.settings)
            }) {
                Image(systemName: viewModel.isPermissionGranted ? "gear" : "exclamationmark.triangle.fill")
                    .foregroundStyle(viewModel.isPermissionGranted ? .gray : .red)
            }
            .accessibilityIdentifier("settingsButton")
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: {
                viewModel.endPomodoroCycle()
                hapticsManager.playClick()
            }) {
                Image(systemName: "stop.fill")
            }
            .accessibilityIdentifier("stopButton")
            
            Button(action: {
                viewModel.resetSession()
                hapticsManager.playClick()
            }) {
                Image(systemName: "arrow.circlepath")
            }
            .accessibilityIdentifier("resetButton")
            
            Button(action: {
                viewModel.skipSession()
                hapticsManager.playClick()
            }) {
                Image(systemName: "forward.end.fill")
            }
            .accessibilityIdentifier("skipButton")
        }
    }
}

 #Preview {
     let viewModel = PomodoroViewModel()
     let coordinator = NavigationCoordinator()
     
     NavigationStack() {
         PomodoroView(viewModel: viewModel)
             .environment(coordinator)
     }
}
