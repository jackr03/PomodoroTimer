//
//  AlertsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 21/09/2024.
//

import Foundation
import WatchKit
import Observation

@Observable
final class AlertsViewModel {
    static let shared = AlertsViewModel()
    
    private var pomodoroTimer = PomodoroTimer.shared
    private var extendedSessionService = ExtendedSessionService.shared
    
    private init() {}
    
    public var showAlert: Bool {
        get { return pomodoroTimer.isTimerFinished }
        set { pomodoroTimer.isTimerFinished = newValue }
    }
    
    func playHaptics() {
        extendedSessionService.playHaptics()
    }
    
    /**
     Haptics can be stopped by just ending the session.
     */
    func stopHaptics() {
        extendedSessionService.stopSession()
    }
    
    func playStartHaptic() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func playPressedHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
}
