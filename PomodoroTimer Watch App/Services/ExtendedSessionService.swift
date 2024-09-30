//
//  ExtendedSessionService.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 20/09/2024.
//

import Foundation
import WatchKit

final class ExtendedSessionService: NSObject, WKExtendedRuntimeSessionDelegate {
    // MARK: - Properties
    static let shared = ExtendedSessionService()
    
    private var session: WKExtendedRuntimeSession?
    private var timer: Timer?

    // MARK: - Init
    private override init() {
        super.init()
    }
    
    // MARK: - Computed properties
    var isRunning: Bool {
        return session?.state == .running
    }
    
    // MARK: - Functions
    // TODO: Remove print statements when confident everything is working
    func startSession() {
        guard session?.state != .running else {
            print("Session already running")
            return
        }
                
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }
    
    func stopSession() {
        guard session?.state != .invalid else {
            print("Session already invalidated")
            return
        }
        
        session?.invalidate()
    }
    
    func playHaptics() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            Haptics.playStop()
        }
    }
    
    func stopHaptics() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Delegate functions
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session expiring")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Session invalidated with reason: \(reason.rawValue), error: \(error?.localizedDescription ?? "No error")")
    }
}
