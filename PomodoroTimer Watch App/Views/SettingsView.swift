//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("workDuration") private var workDuration: Int = SessionType.work.duration
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = SessionType.shortBreak.duration
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = SessionType.longBreak.duration
    
    var body: some View {
        NavigationView{
            Form {
                Picker("Work", selection: $workDuration) {
                    ForEach(1...60, id: \.self) {
                        Text("^[\($0) \("minute")](inflect: true)").tag($0)
                    }
                }
                .onChange(of: workDuration) {
                    // TODO: Reset timer on change
                    print(workDuration)
                }
                
                Picker("Short break", selection: $shortBreakDuration) {
                    ForEach(1...60, id: \.self) {
                        Text("^[\($0) \("minute")](inflect: true)").tag($0)
                    }
                }
                
                Picker("Long break", selection: $longBreakDuration) {
                    ForEach(1...60, id: \.self) {
                        Text("^[\($0) \("minute")](inflect: true)").tag($0)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
