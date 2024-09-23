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
    
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingConfirmAlert = false
    
    var inflectedSessionsCount: String {
        return sessionsCompleted == 1 ? "session" : "sessions"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                HStack {
                    Text("You've completed ")
                        .font(.body)
                    + Text("\(sessionsCompleted)")
                        .bold()
                        .font(.body)
                    + Text(" \(inflectedSessionsCount).")
                        .font(.body)
                }
                .multilineTextAlignment(.center)
                .padding()
                
                Text("Keep up the good work!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingConfirmAlert = true
                        statisticsViewModel.playButtonHaptic()
                    }) {
                        Image(systemName: "trash")
                    }
                    .foregroundStyle(.red)
                    .background(.red.secondary)
                    .clipShape(Capsule())
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
                    statisticsViewModel.playButtonHaptic()
                    
                    dismiss()
                },
                secondaryButton: .cancel(Text("Cancel")) {
                    statisticsViewModel.playButtonHaptic()
                }
            )
        }
    }
}

#Preview {
    StatisticsView()
}
