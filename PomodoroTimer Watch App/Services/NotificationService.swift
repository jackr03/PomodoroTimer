//
//  NotificationService.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 30/09/2024.
//

import Foundation
import UserNotifications

final class NotificationService {
    // MARK: - Properties
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Functions
    // TODO: Ask user to grant permission in settings if not successful
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: Maybe move these into an Enum?
    func notifyUserToResume() {
        notify(title: "Stay focused!",
               body: "Your pomodoro will be paused until you return to the app.",
               sound: .defaultCritical,
               timeInterval: 0.75,
               identifier: "resumeSessionNotification")
    }
    
    // TODO: Add a custom sound for when session's done
    func notifyUserWhenBreakOver(timeTilEnd time: Double) {
        notify(title: "Break's over!",
               body: "Time to get back to work.",
               sound: .default,
               timeInterval: time,
               identifier: "breakOverNotification")
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
    }
    
    // MARK: - Private functions
    func notify(title: String, body: String, sound: UNNotificationSound, timeInterval: Double, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}
