//
//  CoordinatorView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 29/11/2024.
//

import SwiftUI

// TODO: Remove the custom back buttons in the views
struct CoordinatorView: View {
    
    // MARK: - Stored properties
    @State private var coordinator: NavigationCoordinator
    private let pomodoroViewModel: PomodoroViewModel
    
    // MARK: - Inits
    init(coordinator: NavigationCoordinator) {
        self.coordinator = coordinator
        self.pomodoroViewModel = PomodoroViewModel()
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PomodoroView(viewModel: pomodoroViewModel)
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
        .environment(coordinator)
    }
}

#Preview {
    let coordinator = NavigationCoordinator()
    CoordinatorView(coordinator: coordinator)
}
