//
//  ExtendedSessionManager.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 20/09/2024.
//

import Foundation
import WatchKit

final class ExtendedSessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    // MARK: - Properties
    static let shared = ExtendedSessionManager()
    
    private var session: WKExtendedRuntimeSession?
    private var timer: Timer?

    // MARK: - Init
    private override init() {
        super.init()
    }
        
    // MARK: - Functions
    func startSession() {
        guard session?.state != .running else { return }
                
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }
    
    func stopSession() {
        guard session?.state != .invalid else { return }
        
        session?.invalidate()
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
