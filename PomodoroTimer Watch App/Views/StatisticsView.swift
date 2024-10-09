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
    @State private var animateDailyProgressBar = false
    @State private var animateWeeklyPoints = false
    @State private var animateMonthlyPoints = false
    
    // MARK: - Computed properties
    var recordToday: Record { statisticsViewModel.recordToday }
    var recordsThisWeek: [Record] { statisticsViewModel.recordsThisWeek }
    var recordsThisMonth: [Record] { statisticsViewModel.recordsThisMonth}
    
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
//            dailyView
            weeklyView
            monthlyView
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
    // TODO: Overhaul
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
    
    // TODO: Clickable bars to go to the record screen, from which it can be deleted
    // TODO: Could maybe fetch directly from allRecords, which is why .chartXScale is kept here
    // TODO: Clean up, maybe convert this into a @ViewBuilder function and move computed and state variables into it
    var weeklyView: some View {
        VStack {
            Chart {
                ForEach(recordsThisWeek) { record in
                    BarMark(
                        x: .value("Day", record.date, unit: .weekday),
                        y: .value("Sessions completed", animateWeeklyPoints ? record.sessionsCompleted : 0)
                    )
                    .foregroundStyle(record.isDailyTargetMet ? .green : .red)
                    .annotation(position: .top) {
                        Text("\(record.sessionsCompleted)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXScale(domain: Calendar.current.currentWeekRange)
            .chartYScale(domain: 0...((recordsThisWeek.map { $0.sessionsCompleted }.max() ?? 0) + 5))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .chartYAxis(.hidden)
            .padding(.vertical, 10)
            
            Spacer()
            
            Text("Sessions completed")
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .navigationTitle("This week")
        .onAppear() {
            statisticsViewModel.updateRecordsThisWeek()
            withAnimation(.easeInOut(duration: 0.5)) {
                animateWeeklyPoints = true
            }
        }
        .onDisappear() {
             animateWeeklyPoints = false
        }
    }
    
    var monthlyView: some View {
        VStack {
            Chart {
                ForEach(recordsThisMonth) { record in
                    LineMark(
                        x: .value("Day", record.date, unit: .day),
                        y: .value("Sessions completed", animateMonthlyPoints ? record.sessionsCompleted : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                    .symbol(.circle)
                    .symbolSize(30)
                }
            }
            .chartXScale(domain: Calendar.current.currentMonthRange)
            .chartYScale(domain: 0...((recordsThisMonth.map { $0.sessionsCompleted }.max() ?? 0) + 5))
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) {
                    AxisValueLabel(format: .dateTime.day(.defaultDigits), centered: true)
                }
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            Text("Sessions completed")
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .navigationTitle("This month")
        .onAppear() {
            statisticsViewModel.updateRecordsThisMonth()
            withAnimation(.easeInOut(duration: 0.5)) {
                animateMonthlyPoints = true
            }
        }
        .onDisappear() {
            animateMonthlyPoints = false
        }
    }
    
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
    
    // TODO: Reintegrate total and delete button into new allTimeView
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
    // TODO: - Replace reset with SwiftData equivalent
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
    
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
}

#Preview {
    StatisticsView()
}
