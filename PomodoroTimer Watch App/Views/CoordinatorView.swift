//
//  CoordinatorView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 29/11/2024.
//

import SwiftUI

// TODO: Ensure that popToRoot() doesn't remove the base Pomodoro view
// TODO: Remove the custom back buttons in the views
struct CoordinatorView: View {
    
    @Environment(NavigationCoordinator.self) var coordinator
    
    // MARK: - Body
    var body: some View {
        @Bindable var coordinator = coordinator
        
        NavigationStack(path: $coordinator.path) {
            PomodoroView(viewModel: PomodoroViewModel())
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .settings:
                        SettingsView(viewModel: SettingsViewModel())
                    case .statistics:
                        StatisticsView(viewModel: StatisticsViewModel())
                    case .record(let record):
                        RecordView(viewModel: RecordViewModel(record: record))
                    }
                }
        }
    }
}

#Preview {
    CoordinatorView()
        .environment(NavigationCoordinator())
}
