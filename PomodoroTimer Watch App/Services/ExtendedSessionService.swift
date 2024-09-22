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
        session?.start()
    }
    
    func stopSession() {
        guard session?.state == .running else {
            print("Session not running")
            return
        }
        
        session?.invalidate()
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
