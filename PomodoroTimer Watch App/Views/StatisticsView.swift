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
        NavigationStack {
            VStack {
                HStack {
                    Text("You've completed ")
                        .font(.body)
                        .foregroundStyle(.primary)
                    + Text("\(sessionsCompletedToday)/\(dailyTarget)")
                        .bold()
                        .font(.body)
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
                
                Text("Total completed: ")
                    .font(.body)
                    .foregroundStyle(.primary)
                + Text("\(totalSessionsCompleted)")
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .navigationTitle("Statistics")
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
        .alert(isPresented: $showingConfirmAlert) {
            Alert(
                title: Text("Reset Sessions"),
                message: Text("Are you sure you want to reset the number of sessions completed?"),
                primaryButton: .destructive(Text("Confirm")) {
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
