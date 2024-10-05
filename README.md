# Pomodoro Timer 

![screenshot1](https://github.com/user-attachments/assets/f0316f3e-0d77-4106-8c68-8f2ac802b9e9)
![screenshot2](https://github.com/user-attachments/assets/0f6ff631-169a-4fba-bf4d-00aef90718c8)

A simple and minimalistic Pomodoro timer app developed for WatchOS using Swift and SwiftUI. The Pomodoro Technique is a time management method that encourages users to work for (typically) 25 minutes, followed by a short break to maintain productivity.

## Features

- Circular progress bar providing a clear indication of time remaining in the current session
- Smooth, seamless animations
- Haptic feedback when pressing buttons or when sessions end
- Notifications reminding users to resume work sessions when they leave the app and when breaks are over
- Daily targets and tracked work sessions allow users to monitor their productivity
- Optimised for power efficiency by limiting visual updates and animations when the wrist is lowered
- Customisable settings (e.g. work and break durations), stored using Swift's `UserDefaults`
- `WKExtendedRuntimeSession` utilised to ensure the app continues to run in the background
- Supports WatchOS's double-tap gesture for pausing / resuming the timer

![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
