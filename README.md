# Pomodoro Timer

![screenshot1](https://github.com/user-attachments/assets/f0316f3e-0d77-4106-8c68-8f2ac802b9e9)
![screenshot2](https://github.com/user-attachments/assets/0f6ff631-169a-4fba-bf4d-00aef90718c8)

A simple, minimalistic Pomodoro app developed for WatchOS using Swift and SwiftUI following the MVVM architecture.

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
![screenshot3](https://github.com/user-attachments/assets/95263867-fc74-4386-be42-6a5e8dbf4b93)
![screenshot4](https://github.com/user-attachments/assets/2626076e-155a-4ba2-854c-edb58e4d0827)

### Statistics
![screenshot5](https://github.com/user-attachments/assets/d9eb263c-f3e9-47ad-b84a-7ad812b43a30)
![screenshot6](https://github.com/user-attachments/assets/24d3daaf-2381-492d-a6cc-2829c7d9ef42)
![screenshot7](https://github.com/user-attachments/assets/8fd3aef0-a4d7-4842-bf12-2a12a35e3391)
![screenshot8](https://github.com/user-attachments/assets/2f3f3eb9-0d14-4d3a-ae60-c0674d6daa11)

![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
