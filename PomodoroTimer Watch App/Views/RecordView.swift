//
//  RecordView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 12/10/2024.
//

import SwiftUI

struct RecordView: View {
    // MARK: - Properties
    var record: Record
    
    private let viewModel: RecordViewModel
    private let haptics = HapticsManager()
    private let coordinator = NavigationCoordinator.shared
    
    @State private var animateDailyProgress = false
    @State private var showingDeleteRecordAlert = false
    
    // MARK: - Init
    init(record: Record) {
        self.record = record
        self.viewModel = RecordViewModel(record: record)
    }
    
    // MARK: - Computed properties
    var isToday: Bool { record.date == Calendar.current.startOfToday }
    
    var statusMessage: String {
        if record.sessionsCompleted == 0 {
            return "Let's get to work!"
        } else if record.sessionsCompleted > 0 && record.sessionsCompleted < record.dailyTarget {
            return "Keep it up!"
        } else {
            return "Well done!"
        }
    }
    
    var body: some View {
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
            if !isToday {
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
            title: Text("Delete record for \(record.formattedDateShort)?"),
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
    RecordView(record: Record())
}
