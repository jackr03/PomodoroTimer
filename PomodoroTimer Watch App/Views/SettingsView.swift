//
//  SettingsView.swift
//  PomodoroTimer Watch App
//
//  Created by Jack Rong on 10/09/2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    private var settingsViewModel: SettingsViewModel
    
    @AppStorage("workDuration") private var workDuration: Int = 1500
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 300
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 1800
    
    @State private var workDurationInMinutes: Int = 25
    @State private var shortBreakDurationInMinutes: Int = 5
    @State private var longBreakDurationInMinutes: Int = 30
    @State private var haveSettingsChanged = false
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Work", selection: $workDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: workDurationInMinutes) { _, newValue in
                        workDuration = newValue * 60
                    }
                    
                    Picker("Short break", selection: $shortBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: shortBreakDurationInMinutes) { _, newValue in
                        shortBreakDuration = newValue * 60
                    }
                    
                    Picker("Long break", selection: $longBreakDurationInMinutes) {
                        ForEach(1...60, id: \.self) {
                            Text("^[\($0) \("minute")](inflect: true)").tag($0)
                        }
                    }
                    .onChange(of: longBreakDurationInMinutes) { _, newValue in
                        longBreakDuration = newValue * 60
                    }
                }
                .navigationTitle("Settings")
                
                if haveSettingsChanged {
                    Section {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                print("confirm")
                            }) {
                                Image(systemName: "checkmark")
                                    .padding()
                                    .frame(minWidth: 50, minHeight: 50, alignment: .center)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .background(.green)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .cornerRadius(10)

                            Spacer()
                            
                            Button(action: {
                                print("cancel")
                            }) {
                                Image(systemName: "xmark")
                                    .padding()
                                    .frame(minWidth: 50, minHeight: 50, alignment: .center)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .background(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .cornerRadius(10)

                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .onAppear {
            // Update using AppStorage values when view appears
            workDurationInMinutes = workDuration / 60
            shortBreakDurationInMinutes = shortBreakDuration / 60
            longBreakDurationInMinutes = longBreakDuration / 60
        }
    }
}

#Preview {
    let pomodoroTimer = PomodoroTimer()
    let settingsViewModel = SettingsViewModel(pomodoroTimer: pomodoroTimer)
    
    SettingsView(settingsViewModel: settingsViewModel)
}
