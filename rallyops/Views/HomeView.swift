//
//  HomeView.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/28/24.
//

import SwiftUI
import SwiftData

private enum LandingTab: String, CaseIterable, Hashable {
    case today
    case milestones
    case values
    case search
}

struct LandingPageView: View {
    @State private var tabSelection: LandingTab = .today

    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView()
                .tabItem {
                Label("Today", systemImage: "calendar")
                    .symbolVariant(.none)
                    .accessibilityIdentifier("today-tab")
            }.tag(LandingTab.today)

            MilestonesByCoreValueListView()
                .tabItem {
                Label("Milestones", systemImage: "flag.checkered")
                    .symbolVariant(.none)
                    .accessibilityIdentifier("milestones-tab")
            }.tag(LandingTab.milestones)

            CoreValuesView()
                .tabItem {
                Label("Core Values", systemImage: "sparkles")
                    .symbolVariant(.none)
                    .accessibilityIdentifier("core-values-tab")
            }.tag(LandingTab.values)

            SearchView()
                .tabItem {
                Label("Search", systemImage: "magnifyingglass")
                    .symbolVariant(.none)
                    .accessibilityIdentifier("search-tab")
            }.tag(LandingTab.search)
        }
        .environment(\.symbolVariants, .none)
        .onAppear {
            applyOutlineTabIcons()
        }
        .onChange(of: tabSelection) { _, _ in
            applyOutlineTabIcons()
        }
    }

    private func applyOutlineTabIcons() {
        let symbols = ["calendar", "flag.checkered", "sparkles", "magnifyingglass"]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first,
                  let tabBarController = findTabBarController(in: window.rootViewController) else { return }
            tabBarController.tabBar.items?.enumerated().forEach { index, item in
                guard index < symbols.count else { return }
                item.image = UIImage(systemName: symbols[index])
                item.selectedImage = UIImage(systemName: symbols[index])
            }
        }
    }
}

private func findTabBarController(in vc: UIViewController?) -> UITabBarController? {
    guard let vc else { return nil }
    if let tbc = vc as? UITabBarController { return tbc }
    for child in vc.children {
        if let found = findTabBarController(in: child) { return found }
    }
    if let presented = vc.presentedViewController {
        return findTabBarController(in: presented)
    }
    return nil
}

// MARK: - Progress Header

private struct CircularProgressRing: View {
    let progress: Double
    let color: Color

    private let lineWidth: CGFloat = 6
    private let size: CGFloat = 58

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

struct TodayProgressHeader: View {
    @Environment(\.appAccentColor) var accentColor
    @Query(sort: \Action.due) private var allActions: [Action]
    @Query var allHabits: [Habit]

    let showingDate: Date

    private var habitsScheduled: [Habit] {
        allHabits.filter { $0.scheduled(for: showingDate) }
    }

    private var habitsDoneCount: Int {
        habitsScheduled.filter { $0.hasCheckedIn(date: showingDate) }.count
    }

    private var progress: Double {
        guard !habitsScheduled.isEmpty else { return 0 }
        return Double(habitsDoneCount) / Double(habitsScheduled.count)
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Daily Focus")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                if habitsScheduled.isEmpty {
                    Text("No habits scheduled")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else {
                    (Text("You've completed ")
                        + Text("\(habitsDoneCount) of \(habitsScheduled.count)")
                            .foregroundStyle(accentColor)
                            .fontWeight(.semibold)
                        + Text(habitsScheduled.count == 1 ? " habit" : " habits")
                    )
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }

            Spacer()

            if !habitsScheduled.isEmpty {
                CircularProgressRing(progress: progress, color: accentColor)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
    }
}

struct HomeView: View {
    @Environment(\.appAccentColor) var accentColor

    @State private var showingSettings: Bool = false
    @State private var showingCalendar: Bool = false
    @State private var showingCreateAction: Bool = false

    @State private var showingDate: Date = Calendar.current.startOfDay(for: Date())

    private var relativeDayLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(showingDate) { return "Today" }
        if cal.isDateInYesterday(showingDate) { return "Yesterday" }
        return showingDate.formatted(.dateTime.weekday(.wide))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TodayProgressHeader(showingDate: showingDate)

                List {
                    TodayActionItemsView(date: showingDate, onAdd: { showingCreateAction = true })
                    TodayRoutinesView(date: showingDate)
                    TodayMilestonesView(date: showingDate)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(AppTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingCalendar.toggle()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                            VStack(alignment: .leading, spacing: 1) {
                                Text(relativeDayLabel)
                                    .font(.caption2.weight(.bold))
                                Text(showingDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                            }
                        }
                    }
                    .tint(accentColor)
                    .accessibilityLabel("\(relativeDayLabel), \(showingDate.formatted(date: .abbreviated, time: .omitted)), open calendar")
                    .accessibilityIdentifier("calendar-button")
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add Action", systemImage: "plus") {
                        showingCreateAction = true
                    }
                    .accessibilityIdentifier("add-action-button")

                    Button("Settings", systemImage: "gear") {
                        showingSettings.toggle()
                    }
                    .accessibilityIdentifier("settings-button")
                }
            }
            .navigationDestination(for: Milestone.self) { milestone in
                MilestoneView(milestone: milestone)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
        }
        .sheet(isPresented: $showingSettings, content: {
            SettingsView()
        })
        .sheet(isPresented: $showingCalendar, content: {
            CalendarView(showingDate: $showingDate)
        })
        .sheet(isPresented: $showingCreateAction) {
            CreateTodayActionView(defaultDueDate: showingDate)
        }
    }
}

struct TodayActionItemsView: View {
    @Environment(\.appAccentColor) var accentColor
    @Query(sort: \Action.due) private var actions: [Action]

    var date = Date()
    var onAdd: (() -> Void)? = nil

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        let filtered = Action.filter(actions: actions, for: date)
        Section {
            if filtered.isEmpty {
                Text(isToday ? "No actions for today" : "No actions for \(date.formatted(.dateTime.weekday(.wide)))")
                    .font(AppTheme.Typography.callout)
                    .italic()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                ActionItemsListView(actions: filtered)
            }
        } header: {
            Text("Actions")
                .sectionHeaderStyle()
        }
    }
}

struct TodayMilestonesView: View {
    @Query(sort: \Milestone.deadline) private var milestones: [Milestone]

    var date = Date()

    var body: some View {
        let milestones = filteredMilestones()
        Section {
            if milestones.isEmpty {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text("No upcoming milestones")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text("Create a milestone to stay focused on your long-term rallyops.")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
            } else {
                ForEach(milestones) { milestone in
                    NavigationLink(value: milestone) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text(milestone.name)
                                .font(AppTheme.Typography.callout)
                                .strikethrough(milestone.complete)
                                .foregroundStyle(
                                    milestone.complete
                                        ? AppTheme.Colors.textSecondary
                                        : AppTheme.Colors.textPrimary
                                )
                                .lineLimit(3)
                            Text(milestone.core_value?.name ?? "No Core Value")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        } header: {
            Text("Upcoming Milestones")
                .sectionHeaderStyle()
        }
    }

    private func filteredMilestones() -> [Milestone] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        guard let end = cal.date(byAdding: .day, value: 7, to: start) else { return [] }
        return milestones.filter { !$0.complete && $0.deadline >= start && $0.deadline < end }
    }
}

struct CreateTodayActionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var action: Action
    @State private var showCancelConfirmation: Bool = false

    init(defaultDueDate: Date = Date()) {
        _action = State(initialValue: Action("", due: defaultDueDate))
    }

    var body: some View {
        NavigationStack {
            ActionItemEditFields(action: action)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            if hasActionName {
                                showCancelConfirmation = true
                            } else {
                                dismiss()
                            }
                        }
                        .accessibilityIdentifier("action-create-cancel-button")
                        .confirmationDialog("Cancel",
                                            isPresented: $showCancelConfirmation) {
                            Button("Discard Changes", role: .destructive) {
                                dismiss()
                            }
                            Button("Continue Editing", role: .cancel) {
                                showCancelConfirmation = false
                            }
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add", action: save)
                            .disabled(!hasActionName)
                            .accessibilityIdentifier("action-create-save-button")
                    }
                }
                .navigationTitle("New Action")
        }
    }

    private var hasActionName: Bool {
        !action.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        action.name = action.name.trimmingCharacters(in: .whitespacesAndNewlines)
        context.insert(action)
        dismiss()
    }
}

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showingDate: Date

    var body: some View {
        NavigationStack {
            GridCalendarView(showingDate: $showingDate)
                .accessibilityIdentifier("calendar-sheet")
                .padding(.horizontal)
                .padding(.bottom)
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Dismiss the calendar")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Today") {
                        showingDate = Calendar.current.startOfDay(for: Date())
                        dismiss()
                    }
                    .accessibilityLabel("Today")
                    .accessibilityHint("Jump to today and dismiss the calendar")
                }
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Previews

#Preview("Landing Page") {
    do {
        let previewer = try Previewer()
        return LandingPageView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Home") {
    do {
        let previewer = try Previewer()
        return HomeView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Today Action Items") {
    do {
        let previewer = try Previewer()
        return TodayActionItemsView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

// #Preview("Edit Action Item") {
//    EditActionView(action: Action("Not a real action")).modelContainer(CoreValue.preview)
// }
