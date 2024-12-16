//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    // MARK: - Stored properties
    private let hapticsManager = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    
    @State private var viewModel: StatisticsViewModel
    @State private var animateWeeklyPoints = false
    @State private var animateMonthlyPoints = false
    @State private var showingDeleteAllRecordsAlert = false
    
    // MARK: - Inits
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Computed properties
    var recordToday: Record { viewModel.recordToday }
    var recordsThisWeek: [Record] { viewModel.recordsThisWeek }
    var recordsThisMonth: [Record] { viewModel.recordsThisMonth }

    // MARK: - Body
    var body: some View {
        @Bindable var coordinator = coordinator

        TabView {
            dailyStatistics
            weeklyStatistics
            monthlyStatistics
            allTimeStatistics
        }
        .tabViewStyle(.verticalPage)
        .onAppear() {
            viewModel.fetchAllRecords()
        }
        .alert(isPresented: $showingDeleteAllRecordsAlert) {
            deleteAlert()
        }
    }
}

private extension StatisticsView {
    var dailyStatistics: some View {
        let recordViewModel = RecordViewModel(record: recordToday, isOpenedFromAllTimeStatistics: false)
        return RecordView(viewModel: recordViewModel)
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
                        if record.sessionsCompleted > 0 {
                            Text("\(record.sessionsCompleted)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXScale(domain: Calendar.current.weekRange())
            .chartYScale(domain: calculateYDomain(from: recordsThisWeek))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated),
                                   centered: true)
                }
            }
            .chartYAxis(.hidden)
            .padding(.vertical, 10)
            .accessibilityIdentifier("weeklyChart")
            
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
                    if record.sessionsCompleted > 0 {
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
            }
            .chartXScale(domain: Calendar.current.monthRange())
            .chartYScale(domain: calculateYDomain(from: recordsThisMonth))
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) {
                    AxisValueLabel(format: .dateTime.day(.defaultDigits),
                                   centered: true)
                }
            }
            .padding(.vertical, 10)
            .accessibilityIdentifier("monthlyChart")
            
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
                summaryStatistics
                    
                ForEach(viewModel.records) { record in
                    createRecordCard(for: record)
                }
                
                deleteAllRecordsButton
            }
        }
        .navigationTitle("All time")
    }
    
    var summaryStatistics: some View {
        VStack(alignment: .leading) {
            Text("Summary")
                .font(.headline)
            
            Divider()
            
            summaryStatistic(imageName: "checkmark.applewatch",
                             imageColour: .green,
                             label: "Total sessions: \(viewModel.totalSessions)")
            
            summaryStatistic(imageName: "flame",
                             imageColour: .orange,
                             label: "Current streak: \(viewModel.currentStreak)")
            
            summaryStatistic(imageName: "flame",
                             imageColour: .red,
                             label: "Longest streak: \(viewModel.longestStreak)")
            
            summaryStatistic(imageName: "calendar",
                             imageColour: .teal,
                             label: "Total time spent: \(viewModel.totalTimeSpent)")
        }
        .padding()
    }
    
    var deleteAllRecordsButton: some View {
        Button(action: {
            showingDeleteAllRecordsAlert = true
            hapticsManager.playClick()
        }) {
            Image(systemName: "trash")
                .font(.caption)
            Text("Delete all records")
                .font(.caption)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .tint(.red)
        .padding()
        .accessibilityIdentifier("deleteAllRecordsButton")
    }
    
    func summaryStatistic(
        imageName: String,
        imageColour: Color,
        label: String
    ) -> some View {
        HStack(alignment: .top) {
            Image(systemName: imageName)
                .font(.subheadline)
                .foregroundStyle(imageColour)
                .frame(width: 20, height: 20)
            Text(label)
                .font(.caption)
        }
    }
    
    func createRecordCard(for record: Record) -> some View {
        return Button(action: {
            coordinator.push(.record(record: record))
        }) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(record.formattedDate(.medium))")
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
    
    func deleteAlert() -> Alert {
        Alert(
            title: Text("Delete all records?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                viewModel.deleteAllRecords()
                hapticsManager.playSuccess()
                
                coordinator.pop()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                hapticsManager.playClick()
            }
        )
    }
    
    func calculateYDomain(from records: [Record]) -> ClosedRange<Int> {
        let maxSessions = records.map { $0.sessionsCompleted }.max() ?? 0
        return 0...maxSessions + 5
    }
}

#Preview {
    let viewModel = StatisticsViewModel()
    let coordinator = NavigationCoordinator()
    
    NavigationStack() {
        StatisticsView(viewModel: viewModel)
            .environment(coordinator)
    }
}
