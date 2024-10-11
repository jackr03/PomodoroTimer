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
    // MARK: - Properties
    static let shared = NavigationCoordinator()
    
    public var path: [NavigationDestination] = []
    
    // MARK: - Init
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
        case .statistics: StatisticsView()
        case .settings: SettingsView()
        }
    }
}

enum NavigationDestination {
    case statistics
    case settings
}
