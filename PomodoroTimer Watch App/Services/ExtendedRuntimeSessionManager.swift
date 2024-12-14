//
//  ExtendedRuntimeSessionManager.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 20/09/2024.
//

import Foundation
import WatchKit

final class ExtendedRuntimeSessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    
    // MARK: - Stored properties
    private var session: WKExtendedRuntimeSession?

    // MARK: - Inits
    override init() {
        super.init()
    }
        
    // MARK: - Functions
    func startSession() {
        guard session?.state != .running else { return }
                
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        print("Session started")
    }
    
    func stopSession() {
        guard session?.state != .invalid else { return }
        
        session?.invalidate()
        print("Session stopped")
    }
    
    // MARK: - Delegate functions
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Session invalidated with reason: \(reason.rawValue), error: \(error?.localizedDescription ?? "No error")")
    }
}
