//
//  NavigationCoordinator.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 11/10/2024.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class NavigationCoordinator {
    // MARK: - Stored properties
    static let shared = NavigationCoordinator()
    
    public var path: [NavigationDestination] = []
    
    // MARK: - Inits
    private init() {}
    
    // MARK: - Functions
    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    @ViewBuilder
    func destination(for destination: NavigationDestination) -> some View {
        switch destination {
        case .statistics: StatisticsView(viewModel: StatisticsViewModel())
        case .settings: SettingsView()
        case .record(let record): RecordView(record: record)
        }
    }
}

enum NavigationDestination: Hashable {
    case statistics
    case settings
    case record(record: Record)
}
