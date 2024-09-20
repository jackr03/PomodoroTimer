//
//  PomodoroViewModel.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 08/09/2024.
//

import Foundation
import WatchKit

final class PomodoroViewModel: NSObject, WKExtendedRuntimeSessionDelegate {
    private var extendedSession: WKExtendedRuntimeSession?
    private var pomodoroTimer: PomodoroTimer
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
    }
    
    var formattedRemainingTime: String {
        let remainingTimeMinutes: Int = pomodoroTimer.currentRemainingTime / 60
        let remainingTimeSeconds: Int = pomodoroTimer.currentRemainingTime % 60
        
        return String(format: "%02d:%02d", remainingTimeMinutes, remainingTimeSeconds)
    }
    
    var isTimerTicking: Bool {
        return pomodoroTimer.isTimerTickingStatus
    }
    
    var isTimerFinished: Bool {
        return pomodoroTimer.isTimerFinishedStatus
    }
    
    var maxSessions: Int {
        return pomodoroTimer.maxSessions
    }
    
    var currentSession: String {
        return pomodoroTimer.currentSession.displayName
    }
    
    var currentSessionsDone: Int {
        return pomodoroTimer.currentsessionNumber
    }
    
    var isWorkSession: Bool {
        return pomodoroTimer.isWorkSessionStatus
    }
    
    func resetIsTimerFinished() {
        pomodoroTimer.isTimerFinishedStatus = false
    }
    
    func startTimer() {
        self.startExtendedSession()
        pomodoroTimer.startTimer()
    }
    
    func stopTimer() {
        self.endExtendedSession()
        pomodoroTimer.stopTimer()
    }
    
    func pauseTimer() {
        self.endExtendedSession()
        pomodoroTimer.pauseTimer()
    }
    
    func resetTimer() {
        pomodoroTimer.resetTimer()
    }
    
    private func startExtendedSession() {
        extendedSession = WKExtendedRuntimeSession()
        extendedSession?.delegate = self
        extendedSession?.start()
    }
    
    private func endExtendedSession() {
        extendedSession?.invalidate()
        extendedSession = nil
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Session invalidated due to \(reason.rawValue), error: \(error?.localizedDescription ?? "None")")
    }
}
