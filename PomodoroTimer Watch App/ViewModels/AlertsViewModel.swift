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
    private var hapticTimer: Timer?
    
    private init() {}
    
    public var showAlert: Bool {
        get { return pomodoroTimer.isTimerFinished }
        set { pomodoroTimer.isTimerFinished = newValue }
    }
    
    func playStartHaptic() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func startHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            WKInterfaceDevice.current().play(.stop)
        }
    }
    
    func stopHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}
