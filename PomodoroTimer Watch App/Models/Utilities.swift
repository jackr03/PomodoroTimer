//
//  Utilities.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 26/09/2024.
//

import Foundation
import WatchKit

struct Defaults {
    static let defaults = UserDefaults.standard
    
    // MARK: - Integer functions
    static func getIntFrom(_ key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    static func set(_ key: String, to value: Int) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Boolean functions
    static func getBoolFrom(_ key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    static func set(_ key: String, to value: Bool) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Object functions
    static func getObjectFrom(_ key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    static func set(_ key: String, to value: Any?) {
        defaults.set(value, forKey: key)
    }
}

struct Haptics {
    static let device = WKInterfaceDevice.current()
    
    static func playSuccess() {
        device.play(.success)
    }
    
    static func playStart() {
        device.play(.start)
    }
    
    static func playStop() {
        device.play(.stop)
    }
    
    static func playClick() {
        device.play(.click)
    }
}
