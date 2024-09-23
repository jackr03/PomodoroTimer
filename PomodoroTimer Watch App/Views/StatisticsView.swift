//
//  StatisticsView.swift
//  PomodoroTimer
//
//  Created by Jack Rong on 23/09/2024.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                HStack {
                    Text("You've completed ")
                        .font(.body)
                    + Text("\(sessionsCompleted)")
                        .bold()
                        .font(.body)
                    + Text(" sessions.")
                        .font(.body)
                }
                .multilineTextAlignment(.center)
                .padding()
                
                Text("Keep up the good work!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .navigationTitle("Statistics")
            .padding()
        }
    }
}

#Preview {
    StatisticsView()
}
