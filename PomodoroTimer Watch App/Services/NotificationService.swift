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
    
    private var center = UNUserNotificationCenter.current()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Functions
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Successfully received permission")
            } else {
                print("\(error?.localizedDescription ?? "No error description")")
            }
        }
    }
    
    func notifyUserToResume() {
        let content = UNMutableNotificationContent()
        content.title = "Stay focused!"
        content.body = "Your pomodoro will be paused until you return to the app."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.75, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
        center.add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
