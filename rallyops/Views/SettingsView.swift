//
//  SettingsView.swift
//  rallyops
//
//  Created by Cameron Rivers on 5/23/24.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

enum SettingsGroup {
    case about
    case general
    #if DEBUG
    case debug
    #endif
}

struct SettingsView: View {
    // Explicit path binding isolates this NavigationStack from the parent
    // NavigationStack in HomeView, ensuring NavigationLink(value:) taps are
    // handled here rather than being absorbed by the ancestor stack.
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    NavigationLink(value: SettingsGroup.general) {
                        HStack(alignment: .center) {
                            Image(systemName: "gear")

                            Text("General")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.bottom, 1)
                        }
                    }
                    .accessibilityLabel("General")
                    .accessibilityHint("Adjust preferences")
                }
                .accessibilityIdentifier("settings-view")

                Section {
                    NavigationLink(value: SettingsGroup.about) {
                        HStack(alignment: .center) {
                            Image(systemName: "questionmark.circle")

                            Text("About")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.bottom, 1)
                        }
                    }
                    .accessibilityLabel("About")
                    .accessibilityHint("View app information and acknowledgements")

                    #if DEBUG
                    NavigationLink(value: SettingsGroup.debug) {
                        HStack(alignment: .center) {
                            Image(systemName: "ant")

                            Text("Debug")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.bottom, 1)
                        }
                    }
                    .accessibilityLabel("Debug")
                    .accessibilityHint("Access developer tools and data utilities")
                    #endif
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsGroup.self) { screen in
                switch screen {
                case .general:
                    GeneralSettingsView()
                case .about:
                    AboutSettingsView()
                #if DEBUG
                case .debug:
                    DebugSettingsView()
                #endif
                }
            }
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("settings.showCompletedItems") private var showCompletedItems = true
    @AppStorage("settings.startWeekOnMonday") private var startWeekOnMonday = false
    @AppStorage("settings.confirmDestructiveActions") private var confirmDestructiveActions = true
    @AppStorage("settings.accentColorR") private var accentR: Double = 0.26
    @AppStorage("settings.accentColorG") private var accentG: Double = 0.55
    @AppStorage("settings.accentColorB") private var accentB: Double = 0.55

    private var accentColorBinding: Binding<Color> {
        Binding(
            get: { Color(red: accentR, green: accentG, blue: accentB) },
            set: { newColor in
                #if canImport(UIKit)
                let ui = UIColor(newColor)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                ui.getRed(&r, green: &g, blue: &b, alpha: &a)
                accentR = Double(r)
                accentG = Double(g)
                accentB = Double(b)
                #endif
            }
        )
    }

    var body: some View {
        List {
            Section("Appearance") {
                Toggle("Start Week on Monday", isOn: $startWeekOnMonday)
                ColorPicker("Accent Color", selection: accentColorBinding, supportsOpacity: false)
            }

            Section("Preferences") {
                Toggle("Show Completed Items", isOn: $showCompletedItems)
                Toggle("Confirm Destructive Actions", isOn: $confirmDestructiveActions)
            }

            Section("Data") {
                Text("Preferences are stored locally on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutSettingsView: View {
    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            Section("RallyOps") {
                Text("Track values, milestones, actions, and habits in one place.")
                    .font(.body)
                LabeledContent("Version", value: versionText)
            }

            Section("Acknowledgements") {
                acknowledgmentLink("SwiftUI", "https://developer.apple.com/xcode/swiftui/")
                acknowledgmentLink("SwiftData", "https://developer.apple.com/xcode/swiftdata/")
                acknowledgmentLink("SF Symbols", "https://developer.apple.com/sf-symbols/")
            }

            Section("Support") {
                Text("For feedback, open an issue in the project repository.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func acknowledgmentLink(_ title: String, _ urlString: String) -> some View {
        if let url = URL(string: urlString) {
            Link(title, destination: url)
        } else {
            Text(title)
        }
    }
}

#if DEBUG
struct DebugSettingsView: View {
    @Environment(\.modelContext) private var context

    @Query private var values: [CoreValue]
    @Query private var milestones: [Milestone]
    @Query private var actions: [Action]
    @Query private var habits: [Habit]

    @State private var confirmationShown = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(values.count) Core Values")
                    Text("\(milestones.count) Milestones")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(actions.count) Actions")
                    Text("\(habits.count) Habits")
                }
            }
        }
        .font(.caption)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal, 20)

        List {
            Section {
                Button("Add Demo Data") {
                    Previewer.addSampleData(context: context)
                }
                .accessibilityLabel("Add Demo Data")
                .accessibilityHint("Populates the app with sample core values, milestones, actions, and habits")

                Button("Remove App Data", role: .destructive) {
                    confirmationShown = true
                }
                .accessibilityLabel("Remove App Data")
                .accessibilityHint("Deletes all app data permanently")
                .confirmationDialog(
                    "Delete all app data?",
                    isPresented: $confirmationShown,
                    titleVisibility: .visible
                ) {
                    Button("Delete Data", role: .destructive) {
                        do {
                            try context.delete(model: CoreValue.self)
                        } catch {
                        }
                    }

                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

#Preview("Main Settings") {
    SettingsView()
}

#if DEBUG
#Preview("Debug Settings") {
    do {
        let previewer = try Previewer()
        return NavigationStack { DebugSettingsView() }.modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}
#endif

#Preview("General Settings") {
    NavigationStack {
        GeneralSettingsView()
    }
}

#Preview("About Settings") {
    NavigationStack {
        AboutSettingsView()
    }
}
