//
//  NavigationCoordinator.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 11/10/2024.
//

import SwiftUI
import Observation

enum Route: Hashable {
    case statistics
    case settings
    case record(record: Record)
}

@Observable
final class NavigationCoordinator {
    
    // MARK: - Stored properties
    public var path: [Route] = []
    
    // MARK: - Functions
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
}
