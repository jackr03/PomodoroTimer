//
//  RecordView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 12/10/2024.
//

import SwiftUI

struct RecordView: View {
    
    // MARK: - Stored properties
    private let viewModel: RecordViewModel
    private let hapticsManager = HapticsManager()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    
    @State private var animateDailyProgress = false
    @State private var showingDeleteRecordAlert = false
    
    // MARK: - Inits
    init(viewModel: RecordViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        @Bindable var coordinator = coordinator
        
        HStack {
            ProgressView(value: animateDailyProgress ? Double(min(viewModel.sessionsCompleted, viewModel.dailyTarget)) : 0,
                         total: Double(viewModel.dailyTarget))
            .progressViewStyle(LinearProgressViewStyle())
            .tint(viewModel.isDailyTargetMet ? .green : .red)
            .rotationEffect(.degrees(-90))
            .accessibilityIdentifier("dailyProgressBar")
                
            VStack {
                Text("\(viewModel.sessionsCompleted)/\(viewModel.dailyTarget) sessions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("dailySessionsCompleted")
                
                Text("\(viewModel.formattedTimeSpent)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
                    .accessibilityIdentifier("dailyTimeSpent")
                
                // Don't display status message if opened from all time statistics
                if !viewModel.isOpenedFromAllTimeStatistics {
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("dailyStatusMessage")
                }
            }
        }
        .navigationTitle(viewModel.isToday ? "Today" : viewModel.formattedDateMedium)
        .toolbar {
            if viewModel.isOpenedFromAllTimeStatistics {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingDeleteRecordAlert = true
                        hapticsManager.playClick()
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
            deleteAlert()
        }
    }
    
    // MARK: - Functions
    private func deleteAlert() -> Alert {
        Alert(
            title: Text("Delete record for \(viewModel.formattedDateShort)?"),
            message: Text("This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                viewModel.deleteRecord()
                hapticsManager.playSuccess()
                
                coordinator.pop()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                hapticsManager.playClick()
            }
        )
    }
}

#Preview {
    let record = Record(date: Date.now,
                        sessionsCompleted: 5,
                        dailyTarget: 12,
                        timeSpent: 4754)
    let viewModel = RecordViewModel(record: record)
    let coordinator = NavigationCoordinator()
    
    RecordView(viewModel: viewModel)
        .environment(coordinator)
}
