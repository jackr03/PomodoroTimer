//
//  AlertsViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 21/09/2024.
//

import Foundation
import WatchKit

final class AlertsViewModel {
    static let shared = AlertsViewModel()
    
    private var pomodoroTimer = PomodoroTimer.shared
    private var hapticTimer: Timer?

    public var showAlert: Bool = false
    
    private init() {}
    
    var isTimerFinished: Bool {
        return pomodoroTimer.isTimerFinishedStatus
    }
    
    func playStartHaptic() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func startHaptics() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            WKInterfaceDevice.current().play(.stop)
        }
    }
    
    func stopHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        pomodoroTimer.isTimerFinishedStatus = false
    }
}
