//
//  ExtendedSessionService.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 20/09/2024.
//

import Foundation
import WatchKit

final class ExtendedSessionService: NSObject, WKExtendedRuntimeSessionDelegate {
    static let shared = ExtendedSessionService()
    
    private var session: WKExtendedRuntimeSession?

    private override init() {
        super.init()
    }
    
    func startSession() {
        guard session?.state != .running else {
            print("Session already running")
            return
        }
                
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start(at: Date())
    }
    
    func stopSession() {
        guard session?.state != .invalid else {
            print("Session already invalidated")
            return
        }
        
        session?.invalidate()
    }
    
    /**
     Experimental, hard to test as would take 30 minutes to expire
     Idea is to play a haptic to allow future sessions to run without a pop-up warning
     Then, restart the session
     */
    func restartSession() {
        session?.notifyUser(hapticType: .retry)
        
        // Delay before stopping session
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.stopSession()
                
                // Add another delay before starting the session again
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.startSession()
                }
            }
    }
    
    func playHaptics() {
        session?.notifyUser(hapticType: .stop) { _ in
            return 2.0
        }
    }

    // Delegate functions
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session expiring")
        restartSession()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Session invalidated with reason: \(reason.rawValue), error: \(error?.localizedDescription ?? "No error")")
        
    }
    
    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        session = extendedRuntimeSession
        session?.delegate = self
        
        print("Resuming session")
    }
}
