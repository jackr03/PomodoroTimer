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
    private let haptics = HapticsManager()
    
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
                
            VStack {
                Text("\(viewModel.sessionsCompleted)/\(viewModel.dailyTarget) sessions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if viewModel.isToday {
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .navigationTitle(viewModel.isToday ? "Today" : viewModel.formattedDateMedium)
        .toolbar {
            if !viewModel.isToday {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingDeleteRecordAlert = true
                        haptics.playClick()
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
                haptics.playSuccess()
                
                coordinator.pop()
            },
            secondaryButton: .cancel(Text("Cancel")) {
                haptics.playClick()
            }
        )
    }
}

#Preview {
    let record = Record(date: Date.now, sessionsCompleted: 5, dailyTarget: 12)
    let viewModel = RecordViewModel(record: record)
    let coordinator = NavigationCoordinator()
    
    RecordView(viewModel: viewModel)
        .environment(coordinator)
}
