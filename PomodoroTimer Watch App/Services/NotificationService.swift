//
//  NotificationService.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 30/09/2024.
//

import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {
    // MARK: - Properties
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private(set) var permissionsGranted: Bool? = nil
    
    // MARK: - Init
    private init() {
        setUpNotificationCategories()
    }
    
    // MARK: - Functions
    func checkPermissions() async {
        let authorizationStatus = await center.notificationSettings().authorizationStatus
        
        if authorizationStatus == .authorized {
            permissionsGranted = true
        } else if authorizationStatus == .denied {
            permissionsGranted = false
        }
    }
    
    func requestPermissions() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Permission granted")
            } else {
                print("Permissions denied")
            }
            
            Task {
                await self.checkPermissions()
            }
        }
    }
    
    func notifyUserToResume() {
        notify(title: "Stay focused!",
               body: "Your pomodoro will be paused until you return to the app.",
               sound: .defaultCritical,
               timeInterval: 0.75,
               identifier: "resumeSessionNotification")
    }
    
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
    private func setUpNotificationCategories() {
        let openAppAction = UNNotificationAction(identifier: "openAppAction",
                                                 title: "Open app",
                                                 options: .foreground)
        
        let pomodoroCategory = UNNotificationCategory(identifier: "pomodoroCategory",
                                              actions: [openAppAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        center.setNotificationCategories([pomodoroCategory])
    }
    
    private func notify(title: String, body: String, sound: UNNotificationSound, timeInterval: Double, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.categoryIdentifier = "pomodoroCategory"
        
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
