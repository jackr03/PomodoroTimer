//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import SwiftUI

struct StatisticsView: View {
    // MARK: - Properties
    private let statisticsViewModel = StatisticsViewModel.shared
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("totalSessionsCompleted") private var totalSessionsCompleted: Int = 0
    @AppStorage("sessionsCompletedToday") private var sessionsCompletedToday: Int = 0
    @AppStorage("dailyTarget") private var dailyTarget: Int = 12
        
    @State private var showingDeletionAlert = false
    
    // MARK: - Computed properties
    var inflectedSessionsCount: String {
        sessionsCompletedToday == 1 ? "session" : "sessions"
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
    
    // MARK: - View
    var body: some View {
        TabView {
            testView
            dailyView
            allTimeView
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
        .onChange(of: statisticsViewModel.isSessionFinished) { _, isFinished in
            if isFinished {
                dismiss()
            }
        }
        .alert(isPresented: $showingDeletionAlert) {
            deletionAlert
        }
    }
}

private extension StatisticsView {
    var testView: some View {
        VStack {
            Button("Add record") {
                statisticsViewModel.addNewRecord()
            }
            
            Button("Remove all records") {
                statisticsViewModel.deleteAllRecords()
            }
            
            List {
                ForEach(statisticsViewModel.records) { record in
                    Text("\(record.date)")
                 }
                .onDelete(perform: statisticsViewModel.deleteRecord)
            }
        }
        
        
    }
    // TODO: Add a progress bar
    var dailyView: some View {
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
    }
    
    // TODO: Add a graph of how many were done over the past week
    var allTimeView: some View {
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
                        showingDeletionAlert = true
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
    
    var deletionAlert: Alert {
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

#Preview {
    StatisticsView()
}
