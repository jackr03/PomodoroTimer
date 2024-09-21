//
//  ExtendedSessionService.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 20/09/2024.
//

import Foundation
import WatchKit

final class ExtendedSessionService: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?
    private var hapticTimer: Timer?
    
    func startSession() {
        guard session?.state != .running else {
            print("Session already running")
            return
        }
        
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        
        playStartHaptic()
    }
    
    func stopSession() {
        guard session?.state == .running else {
            print("Session not running")
            return
        }
        
        session?.invalidate()
    }
    
    private func playStartHaptic() {
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
    }

    // Delegate functions
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session expiring")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        session = nil
        print("Session invalidated with reason: \(reason.rawValue), error: \(error?.localizedDescription ?? "No error")")
    }
}
