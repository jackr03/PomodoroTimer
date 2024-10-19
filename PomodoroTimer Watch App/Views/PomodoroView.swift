//
//  PomoroView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import SwiftUI

struct PomodoroView: View {
    // MARK: - Properties
    @Bindable private var viewModel = PomodoroViewModel.shared
    @Bindable private var coordinator = NavigationCoordinator.shared
    
    private let haptics = HapticsManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var lastInactiveTime = Date.now
    @State private var isPulsing = false
    @State private var hapticTimer: Timer?
    
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
        NavigationStack(path: $coordinator.path) {
            VStack() {
                circularProgressBar
            }
            .ignoresSafeArea()
            .navigationDestination(for: NavigationDestination.self) { destination in
                coordinator.destination(for: destination)
            }
            .toolbar {
                if !isScreenInactive && !viewModel.isSessionFinished {
                    toolbarItems()
                }
            }
            .onAppear {
                viewModel.checkPermissions()
            }
            .onChange(of: viewModel.isSessionFinished) { _, isFinished in
                if isFinished {
                    coordinator.popToRoot()
                    viewModel.incrementWorkSessionsCompleted()
                    playHaptics()
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handlePhaseChange(oldPhase, newPhase)
            }
        }
        .background(viewModel.isSessionFinished ? .white : .clear)
    }
    
    // MARK: - Private functions
    private func handlePhaseChange(_ oldPhase: ScenePhase, _ newPhase: ScenePhase) {
        // Slow down updates if screen is inactive
        switch (oldPhase, newPhase) {
        case (.inactive, .active):
            viewModel.stopCachingTimeAndProgress()
        case (.active, .inactive):
            viewModel.startCachingTimeAndProgress()
        default:
            break
        }
        
        guard viewModel.isTimerTicking else { return }
        
        switch (oldPhase, newPhase) {
        // If user has left in the middle of a work session, send a notification
        case (.active, .inactive) where viewModel.isWorkSession:
            viewModel.notifyUserToResume()
        // Record time when user closed app and queue a notification to remind them when break ends
        case (.active, .inactive) where !viewModel.isWorkSession:
            lastInactiveTime = Date.now
            viewModel.notifyUserWhenBreakOver()
        // Restart the extended session if the user comes back
        case (.background, .inactive) where viewModel.isWorkSession:
            viewModel.startExtendedSession()
        // Deduct time from the break session and restart the session if there is still time remaining
        // Cancel notification regardless
        case (.background, .inactive) where !viewModel.isWorkSession:
            let secondsSinceLastInactive = Int(lastInactiveTime.distance(to: Date.now))
            if viewModel.deductBreakTime(by: secondsSinceLastInactive) > 0 {
                viewModel.startExtendedSession()
            }
            
            viewModel.cancelBreakOverNotification()
        default:
            break
        }
    }
    
    private func buttonAction() {
        if isSessionFinished {
            stopHaptics()
            viewModel.prepareForNextSession()
            haptics.playClick()
        } else {
            if viewModel.isTimerTicking {
                viewModel.pauseTimer()
                haptics.playClick()
            } else {
                viewModel.startTimer()
                haptics.playStart()
            }
        }
    }
    
    private func playHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            haptics.playStop()
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
    var activeSessionView: some View {
        VStack {
            if !isScreenInactive {
                HStack {
                    Text(viewModel.currentSession)
                        .font(.caption.bold())
                        .foregroundStyle(Color.secondary)
                        .minimumScaleFactor(0.5)
                    
                    Text("\(viewModel.currentSessionsDone)/\(viewModel.maxSessions)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.top, 12)
            } else {
                Spacer()
                    .frame(height: 24)
            }
            
            Text(time)
                .font(.title.bold())
                .foregroundStyle(Color.primary)
            
            Image(systemName: viewModel.isTimerTicking ? "pause.fill" : "play.fill")
                .foregroundStyle(Color.primary)
                .padding(.top, 6)
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
            
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .padding(.top, 18)
        }
    }
    
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
    
    @ToolbarContentBuilder
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                coordinator.push(.statistics)
            }) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.gray)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                coordinator.push(.settings)
            }) {
                if viewModel.isPermissionGranted {
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
                viewModel.endCycle()
                haptics.playClick()
            }) {
                Image(systemName: "stop.fill")
            }
            
            Button(action: {
                viewModel.resetTimer()
                haptics.playClick()
            }) {
                Image(systemName: "arrow.circlepath")
            }
            
            Button(action: {
                viewModel.skipSession()
                haptics.playClick()
            }) {
                Image(systemName: "forward.end.fill")
            }
        }
    }
}

 #Preview {
    PomodoroView()
}
