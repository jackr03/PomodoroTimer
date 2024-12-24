# Pomodoro Timer
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/swiftui-007AFF?style=for-the-badge&logo=swift&logoColor=white)

![screenshot1](https://github.com/user-attachments/assets/f0316f3e-0d77-4106-8c68-8f2ac802b9e9)
![screenshot2](https://github.com/user-attachments/assets/0f6ff631-169a-4fba-bf4d-00aef90718c8)

A simple, minimalistic Pomodoro app built for WatchOS using Swift and SwiftUI following the MVVM architecture. Developed using test-driven development (TDD), with unit and UI tests implemented using the XCTest and Swift Testing frameworks respectively.

## Features

- Circular progress bar providing a clear indication of time remaining in the current session
- Utilises `SwiftData` for efficient data management and persistence of user records
- User records visualisation using `SwiftCharts`, allowing users to monitor their productivity
- Customisable settings (e.g. work and break durations), stored using Swift's `UserDefaults`
- `WKExtendedRuntimeSession` used to ensure the app continues to run in the background
- Supports WatchOS's double-tap gesture for pausing / resuming the timer
- Smooth, seamless animations
- Optimised for power efficiency by limiting visual updates and animations when the wrist is lowered
- Haptic feedback when pressing buttons or when sessions end
- Notifications reminding users to resume work sessions when they leave the app and when breaks are over

## Screenshots

### Settings
![screenshot3](https://github.com/user-attachments/assets/8e9ca2ab-8b27-47d2-b3cd-c90f5aeadeb2)
![screenshot4](https://github.com/user-attachments/assets/53c6f971-6ce4-4814-a613-ce36b31d404c)

### Statistics
![screenshot5](https://github.com/user-attachments/assets/fc6eb039-69ab-4419-b5c0-37bd4ce1a7e7)
![screenshot6](https://github.com/user-attachments/assets/24d3daaf-2381-492d-a6cc-2829c7d9ef42)
![screenshot7](https://github.com/user-attachments/assets/8fd3aef0-a4d7-4842-bf12-2a12a35e3391)
![screenshot8](https://github.com/user-attachments/assets/a66dd4dd-d38a-428b-acff-6d631bc08f97)
