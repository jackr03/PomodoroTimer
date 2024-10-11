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
        .alert(isPresented: $showingDeletionAlert) {
            deleteAlert
        }
    }
}

private extension StatisticsView {
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
    
    // TODO: Overhaul
    // TODO: Add a progress bar
    var dailyStatistics: some View {
        HStack {
            ProgressView(value: Double(min(recordToday.sessionsCompleted, recordToday.dailyTarget)),
                         total: Double(recordToday.dailyTarget))
            .progressViewStyle(LinearProgressViewStyle())
            .tint(recordToday.isDailyTargetMet ? .green : .red)
            .rotationEffect(.degrees(-90))
                
            VStack {
                Text("\(recordToday.sessionsCompleted)/\(recordToday.dailyTarget) sessions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Today")
    }
    
    // TODO: Clickable bars to go to the record screen, from which it can be deleted
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
            .chartYScale(domain: calculateYDomain(recordsThisWeek))
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
            .chartYScale(domain: calculateYDomain(recordsThisMonth))
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
    // TODO: Clickable cards
    var allTimeStatistics: some View {
        ScrollView {
            LazyVStack {
                summaryCard
                .padding()
                .padding(.bottom, 10)
                    
                ForEach(statisticsViewModel.records) { record in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(record.formattedDate)")
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
            }
            
            Section {
                deleteAllRecordsButton
            }
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
                    Image(systemName: "checkmark.seal") // Icon for total sessions
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Total sessions: \(statisticsViewModel.totalSessions)")
                        .font(.body)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Current streak: \(statisticsViewModel.currentStreak)")
                        .font(.body)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text("Longest streak: \(statisticsViewModel.longestStreak)")
                        .font(.body)
                }
            }
        }
    }
    
    var deleteAllRecordsButton: some View {
        Button(action: {
            showingDeletionAlert = true
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
    
    var deleteAlert: Alert {
        Alert(
            title: Text("Delete all records?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                statisticsViewModel.deleteAllRecords()
                Haptics.playSuccess()
                
                dismiss()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                Haptics.playClick()
            }
        )
    }
    
    func calculateYDomain(_ records: [Record]) -> ClosedRange<Int> {
        0...((records.map { $0.sessionsCompleted }.max() ?? 0) + 5)
    }
}

extension Record {
    var formattedDate: String {
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
