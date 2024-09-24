//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
    private let statisticsViewModel = StatisticsViewModel.shared
    
    @AppStorage("totalSessionsCompleted") private var totalSessionsCompleted: Int = 0
    @AppStorage("sessionsCompletedToday") private var sessionsCompletedToday: Int = 0
    @AppStorage("dailyTarget") private var dailyTarget: Int = 0
        
    @State private var showingConfirmAlert = false
    
    @Environment(\.dismiss) private var dismiss

    var inflectedSessionsCount: String {
        return sessionsCompletedToday == 1 ? "session" : "sessions"
    }
    
    var statusMessage: String {
        if sessionsCompletedToday == 0 {
            return "Let's get to work!"
        } else if sessionsCompletedToday > 0 && sessionsCompletedToday < dailyTarget {
            return "Keep up the good work!"
        } else {
            return "Well done!"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
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
                
                Spacer()
                
                Text("Total completed: ")
                    .font(.body)
                    .foregroundStyle(.primary)
                + Text("\(totalSessionsCompleted)")
                    .font(.title3)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .navigationTitle("Statistics")
            .toolbar {
                if totalSessionsCompleted > 0 {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            showingConfirmAlert = true
                            statisticsViewModel.playClickHaptic()
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
                    statisticsViewModel.playSuccessHaptic()
                    
                    dismiss()
                },
                secondaryButton: .cancel(Text("Cancel")) {
                    statisticsViewModel.playClickHaptic()
                }
            )
        }
    }
}

#Preview {
    StatisticsView()
}
