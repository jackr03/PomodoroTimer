//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    // MARK: - Properties
    private let statisticsViewModel = StatisticsViewModel.shared
    
    @Environment(\.dismiss) private var dismiss
        
    @State private var showingDeletionAlert = false
    
    // MARK: - Computed properties
    var recordToday: Record { statisticsViewModel.recordToday }
    var recordsThisWeek: [Record?] { statisticsViewModel.recordsThisWeek }
    
    var statusMessage: String {
        if recordToday.sessionsCompleted == 0 {
            return "Let's get to work!"
        } else if recordToday.sessionsCompleted > 0 && recordToday.sessionsCompleted < recordToday.dailyTarget {
            return "Keep it up!"
        } else {
            return "Well done!"
        }
    }
    
    // MARK: - View
    var body: some View {
        TabView {
            dailyView
            weeklyView
//            monthlyView
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
    // TODO: Add a progress bar
    var dailyView: some View {
        VStack {
            Spacer()
            
            Text("\(recordToday.sessionsCompleted)/\(recordToday.dailyTarget)")
                .font(.title)
                .foregroundStyle(.primary)
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
        .navigationTitle("Today")
        .onAppear() {
            statisticsViewModel.updateRecordToday()
        }
    }
    
    // TODO: Shorten days of the week, decrease size of chart and other UI improvements
    var weeklyView: some View {
        Chart {
            ForEach(recordsThisWeek.indices, id: \.self) { index in
                let normalisedIndex = (index + 1) % 7
                let day = Calendar.current.weekdaySymbols[normalisedIndex]
                
                BarMark(
                    x: .value("Day", day),
                    y: .value("Sessions completed", recordsThisWeek[index]?.sessionsCompleted ?? 0 )
                )
            }
        }
        .navigationTitle("This week")
        .onAppear() {
            statisticsViewModel.updateRecordsThisWeek()
        }
    }
    
//    var monthlyView: some View {
//        List {
//            ForEach(statisticsViewModel.recordsThisMonth) { record in
//                HStack {
//                    Text("\(record.formattedDate)")
//                    Text("\(record.sessionsCompleted)/\(record.dailyTarget)")
//                }
//            }
//        }
//        .navigationTitle("This month")
//        .onAppear() {
//            statisticsViewModel.updateRecordsThisMonth()
//        }
//    }
    
    var allTimeView: some View {
        VStack {
            Button("Add") {
                statisticsViewModel.addRecord()
            }
            
            Button("Delete") {
                statisticsViewModel.deleteAllRecords()
            }
            List {
                ForEach(statisticsViewModel.allRecords) { record in
                    HStack {
                        Text("\(record.formattedDate)")
                        Text("\(record.sessionsCompleted)/\(record.dailyTarget)")
                    }
                    .listRowBackground(record.isDailyTargetMet ? Color.green : Color.red)
                }
                .onDelete(perform: statisticsViewModel.deleteRecord)
            }
        }
        .navigationTitle("All time")
        .onAppear() {
            statisticsViewModel.updateAllRecords()
        }
    }
    
    // TODO: Add a graph of how many were done over the past week
//    var allTimeView: some View {
//        VStack {
//            Spacer()
//            
//            HStack {
//                Text("Total completed: ")
//                    .font(.body)
//                    .foregroundStyle(.primary)
//                + Text("\(totalSessionsCompleted)")
//                    .font(.body)
//                    .bold()
//                    .foregroundStyle(.primary)
//            }
//            .multilineTextAlignment(.center)
//
//            Spacer()
//            Spacer()
//        }
//        .toolbar {
//            if totalSessionsCompleted > 0 {
//                ToolbarItem(placement: .bottomBar) {
//                    Button(action: {
//                        showingDeletionAlert = true
//                        Haptics.playClick()
//                    }) {
//                        Image(systemName: "trash")
//                    }
//                    .foregroundStyle(.red)
//                    .background(.red.secondary)
//                    .clipShape(Capsule())
//                }
//            }
//        }
//        .padding()
//    }
//
    // TODO: - Replace this with SwiftData equivalent
    var deletionAlert: Alert {
        Alert(
            title: Text("Reset sessions?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
//                statisticsViewModel.resetSessions()
                Haptics.playSuccess()
                
                dismiss()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                Haptics.playClick()
            }
        )
    }
}

extension Record {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}

#Preview {
    StatisticsView()
}
