//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
    // MARK: - Properties
    private let statisticsViewModel = StatisticsViewModel.shared
    
    @AppStorage("totalSessionsCompleted") private var totalSessionsCompleted: Int = 0
    @AppStorage("sessionsCompletedToday") private var sessionsCompletedToday: Int = 0
    @AppStorage("dailyTarget") private var dailyTarget: Int = 12
        
    @State private var showingConfirmAlert = false
    
    @Environment(\.dismiss) private var dismiss

    // MARK: - Computed properties
    var inflectedSessionsCount: String {
        return sessionsCompletedToday == 1 ? "session" : "sessions"
    }
    
    var statusMessage: String {
        if sessionsCompletedToday == 0 {
            return "Let's get to work!"
        } else if sessionsCompletedToday > 0 && sessionsCompletedToday < dailyTarget {
            return "Keep it up!"
        } else {
            return "Well done!"
        }
    }
    
    // MARK: - Body
    var body: some View {
        TabView {
            // TODO: Progress bar?
            VStack {
                Spacer()
                
                HStack {
                    Text("You've completed ")
                        .font(.body)
                        .foregroundStyle(.primary)
                    + Text("\(sessionsCompletedToday)/\(dailyTarget)")
                        .font(.body)
                        .bold()
                        .foregroundStyle(.primary)
                    + Text(" \(inflectedSessionsCount) today.")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .multilineTextAlignment(.center)
                
                Spacer()
                
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                Spacer()
            }
            .padding()
            
            // TODO: Add a graph of how many were done over the past week
            VStack {
                Spacer()
                
                HStack {
                    Text("Total completed: ")
                        .font(.body)
                        .foregroundStyle(.primary)
                    + Text("\(totalSessionsCompleted)")
                        .font(.body)
                        .bold()
                        .foregroundStyle(.primary)
                }
                .multilineTextAlignment(.center)

                Spacer()
                Spacer()
            }
            .toolbar {
                if totalSessionsCompleted > 0 {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            showingConfirmAlert = true
                            Haptics.playClick()
                        }) {
                            Image(systemName: "trash")
                        }
                        .foregroundStyle(.red)
                        .background(.red.secondary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle("Statistics")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                .handGestureShortcut(.primaryAction)
            }
        }
        .alert(isPresented: $showingConfirmAlert) {
            Alert(
                title: Text("Reset sessions?"),
                message: Text("This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    statisticsViewModel.resetSessions()
                    Haptics.playSuccess()
                    
                    dismiss()
                },
                secondaryButton: .cancel(Text("Cancel")) {
                    Haptics.playClick()
                }
            )
        }
    }
}

#Preview {
    StatisticsView()
}
