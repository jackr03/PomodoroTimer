//
//  HapticsManager.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 19/10/2024.
//

import Foundation
import WatchKit

struct HapticsManager {
    private let device = WKInterfaceDevice.current()
    
    func playSuccess() {
        device.play(.success)
    }
    
    func playStart() {
        device.play(.start)
    }
    
    func playStop() {
        device.play(.stop)
    }
    
    func playClick() {
        device.play(.click)
    }
}
