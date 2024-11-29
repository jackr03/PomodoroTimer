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
    @State private var viewModel: StatisticsViewModel
    private let haptics = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    coordinator.pop()
                }) {
                    Image(systemName: "chevron.left")
                }
                .handGestureShortcut(.primaryAction)
            }
        }
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
        let recordViewModel = RecordViewModel(record: recordToday)
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
                    
                ForEach(viewModel.records) { record in
                    createRecordCard(for: record)
                }
            }
            
            Button(action: {
                showingDeleteAllRecordsAlert = true
                haptics.playClick()
            }) {
                Image(systemName: "trash")
                    .font(.footnote)
                Text("Delete all records")
                    .font(.footnote)
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .tint(.red)
        }
        .navigationTitle("All time")
    }
    
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
                    Text("Total sessions: \(viewModel.totalSessions)")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    Text("Current streak: \(viewModel.currentStreak)")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    Text("Longest streak: \(viewModel.longestStreak)")
                        .font(.subheadline)
                }
            }
        }
    }
    
    func createRecordCard(for record: Record) -> some View {
        return Button(action: {
            coordinator.push(.record(record: record))
        }) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(record.formatDate(.medium))")
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
                haptics.playSuccess()
                
                coordinator.pop()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                haptics.playClick()
            }
        )
    }
    
    func calculateYDomain(from records: [Record]) -> ClosedRange<Int> {
        let maxSessions = records.map { $0.sessionsCompleted }.max() ?? 0
        return 0...maxSessions + 5
    }
}

extension AppStorage {
    init(wrappedValue: Value, _ key: IntSetting, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
    
    init(wrappedValue: Value, _ key: BoolSetting, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}

#Preview {
    let viewModel = StatisticsViewModel()
    let coordinator = NavigationCoordinator()
    
    StatisticsView(viewModel: viewModel)
        .environment(coordinator)
}
