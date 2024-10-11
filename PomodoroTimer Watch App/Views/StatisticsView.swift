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
    
    @State private var showingDeleteRecordAlert = false
    @State private var showingDeleteAllRecordsAlert = false
    @State private var animateDailyProgress = false
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
            dailyStatistics
            weeklyStatistics
            monthlyStatistics
            allTimeStatistics
        }
        .tabViewStyle(.verticalPage)
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
        .alert(isPresented: $showingDeleteAllRecordsAlert) {
            deleteAlert()
        }
    }
}

private extension StatisticsView {
    var dailyStatistics: some View {
        recordStatistics(for: recordToday, isToday: true)
    }
    
    // TODO: Clickable bars to go to the record screen
    var weeklyStatistics: some View {
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
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated),
                                   centered: true)
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
            withAnimation(.easeInOut(duration: 0.5)) {
                animateWeeklyPoints = true
            }
        }
        .onDisappear() {
             animateWeeklyPoints = false
        }
    }
    
    var monthlyStatistics: some View {
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
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) {
                    AxisValueLabel(format: .dateTime.day(.defaultDigits),
                                   centered: true)
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
            withAnimation(.easeInOut(duration: 0.5)) {
                animateMonthlyPoints = true
            }
        }
        .onDisappear() {
            animateMonthlyPoints = false
        }
    }
    
    // TODO: Collapsible sections by month
    var allTimeStatistics: some View {
        ScrollView {
            LazyVStack {
                summaryCard
                .padding()
                .padding(.bottom, 10)
                    
                ForEach(statisticsViewModel.records) { record in
                    NavigationLink(destination: recordStatistics(for: record)) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(record.formattedDateMedium)")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(record.sessionsCompleted)/\(record.dailyTarget)")
                                        .font(.body.bold())
                                        .foregroundStyle(.primary)
                                }
                                
                                ProgressView(value: Double(min(record.sessionsCompleted, record.dailyTarget)),
                                             total: Double(record.dailyTarget))
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(record.isDailyTargetMet ? .green : .red)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Button(action: {
                showingDeleteAllRecordsAlert = true
                Haptics.playClick()
            }) {
                Image(systemName: "trash")
                    .font(.caption)
                Text("Delete all records")
                    .font(.caption)
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .tint(.red)
        }
        .navigationTitle("All time")
    }
    
    // TODO: Implement actual logic behind computed variables
    var summaryCard: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Summary")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                HStack {
                    Image(systemName: "checkmark.seal")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Text("Total sessions: \(statisticsViewModel.totalSessions)")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    Text("Current streak: \(statisticsViewModel.currentStreak)")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    Text("Longest streak: \(statisticsViewModel.longestStreak)")
                        .font(.subheadline)
                }
            }
        }
    }
    
    // FIXME: Need to fix views, by popping off the stack
    func recordStatistics(for record: Record, isToday: Bool = false) -> some View {
        HStack {
            ProgressView(value: animateDailyProgress ? Double(min(record.sessionsCompleted, record.dailyTarget)) : 0,
                         total: Double(record.dailyTarget))
            .progressViewStyle(LinearProgressViewStyle())
            .tint(record.isDailyTargetMet ? .green : .red)
            .rotationEffect(.degrees(-90))
                
            VStack {
                Text("\(record.sessionsCompleted)/\(record.dailyTarget) sessions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if isToday {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .navigationTitle(isToday ? "Today" : record.formattedDateMedium)
        .toolbar {
            if !isToday {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingDeleteRecordAlert = true
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
        .onAppear() {
            withAnimation(.easeInOut(duration: 0.5)) {
                animateDailyProgress = true
            }
        }
        .onDisappear() {
            animateDailyProgress = false
        }
        .alert(isPresented: $showingDeleteRecordAlert) {
            deleteAlert(record)
        }
    }
    
    func deleteAlert(_ record: Record? = nil) -> Alert {
        let title: String
        let deleteAction: () -> Void
        
        if let record = record {
            title = "Delete record for \(record.formattedDateShort)?"
            deleteAction = {
                statisticsViewModel.deleteRecord(record)
            }
        } else {
            title = "Delete all records?"
            deleteAction = {
                statisticsViewModel.deleteAllRecords()
            }
        }
        
        return Alert(
            title: Text(title),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                deleteAction()
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
    var formattedDateShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: date)

    }
    
    var formattedDateMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    
    var isDailyTargetMet: Bool { sessionsCompleted >= dailyTarget }
}

#Preview {
    StatisticsView()
}
