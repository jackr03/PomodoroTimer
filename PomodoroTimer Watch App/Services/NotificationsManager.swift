//
//  NotificationsManager.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 30/09/2024.
//

import Foundation
import UserNotifications

final class NotificationsManager {
    
    // MARK: - Stored properties
    private let center: UNUserNotificationCenter
    
    private(set) var permissionsGranted: Bool?
    
    // MARK: - Init
    init() {
        self.center = UNUserNotificationCenter.current()
        
        Task {
            await checkPermission()
        }
        
        setUpNotificationCategories()
    }
    
    // MARK: - Functions
    func checkPermission() async {
        let authorizationStatus = await center.notificationSettings().authorizationStatus
        
        switch authorizationStatus {
        case .authorized:
            permissionsGranted = true
        case .denied:
            permissionsGranted = false
        default:
            permissionsGranted = nil
        }
    }
    
    func requestPermissions() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            print(granted ? "Permission granted" : "Permission denied")
            self.permissionsGranted = granted
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
    
    func clearNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
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
    
    private func notify(
        title: String,
        body: String,
        sound: UNNotificationSound,
        timeInterval: Double,
        identifier: String
    ) {
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
