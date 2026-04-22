//
//  RallyOpsApp.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/16/24.
//

import SwiftUI
import SwiftData

@main
struct RallyOpsApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            CoreValue.self,
            Milestone.self,
            Action.self,
            Habit.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
