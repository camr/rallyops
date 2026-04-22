//
//  SearchView.swift
//  rallyops
//
//  Global search across Core Values, Milestones, Actions, and Habits.
//

import SwiftUI
import SwiftData

// MARK: - Result types

enum SearchResult: Identifiable {
    case coreValue(CoreValue)
    case milestone(Milestone)
    case action(Action)
    case habit(Habit)

    var id: String {
        switch self {
        case .coreValue(let v): return "cv-\(v.persistentModelID)"
        case .milestone(let m): return "ms-\(m.persistentModelID)"
        case .action(let a): return "ac-\(a.persistentModelID)"
        case .habit(let h): return "hb-\(h.persistentModelID)"
        }
    }

    var title: String {
        switch self {
        case .coreValue(let v): return v.name
        case .milestone(let m): return m.name
        case .action(let a): return a.name
        case .habit(let h): return h.name
        }
    }

    var subtitle: String {
        switch self {
        case .coreValue(let v):
            let count = v.milestones.count
            return count == 1 ? "1 milestone" : "\(count) milestones"
        case .milestone(let m):
            return m.core_value?.name ?? "No Core Value"
        case .action(let a):
            if let due = a.due {
                return due.formatted(date: .abbreviated, time: .omitted)
            }
            return a.milestone?.name ?? "No Milestone"
        case .habit(let h):
            return h.milestone?.name ?? h.core_value?.name ?? ""
        }
    }

    var category: String {
        switch self {
        case .coreValue: return "Core Values"
        case .milestone: return "Milestones"
        case .action: return "Actions"
        case .habit: return "Habits"
        }
    }

    var systemImage: String {
        switch self {
        case .coreValue: return "triangle.circle.fill"
        case .milestone: return "flag.checkered.circle.fill"
        case .action: return "checkmark.circle"
        case .habit: return "repeat.circle"
        }
    }
}

// MARK: - Search View

struct SearchView: View {
    @Query(sort: \CoreValue.name) private var coreValues: [CoreValue]
    @Query(sort: \Milestone.name) private var milestones: [Milestone]
    @Query(sort: \Action.name) private var actions: [Action]
    @Query(sort: \Habit.name) private var habits: [Habit]

    @State private var query: String = ""

    private var results: [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        let lower = trimmed.lowercased()

        var out: [SearchResult] = []
        out += coreValues.filter { $0.name.localizedCaseInsensitiveContains(lower) }.map { .coreValue($0) }
        out += milestones.filter { $0.name.localizedCaseInsensitiveContains(lower) }.map { .milestone($0) }
        out += actions.filter { $0.name.localizedCaseInsensitiveContains(lower) }.map { .action($0) }
        out += habits.filter { $0.name.localizedCaseInsensitiveContains(lower) }.map { .habit($0) }
        return out
    }

    var body: some View {
        NavigationStack {
            Group {
                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    searchPrompt
                } else if results.isEmpty {
                    noResults
                } else {
                    resultsList
                }
            }
            .navigationTitle("Search")
            .navigationDestination(for: CoreValue.self) { value in
                CoreValueDetailsView(value: value)
            }
            .navigationDestination(for: Milestone.self) { milestone in
                MilestoneView(milestone: milestone)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search values, milestones, actions, habits")
    }

    // MARK: - Sub-views

    private var searchPrompt: some View {
        ContentUnavailableView(
            "Search",
            systemImage: "magnifyingglass",
            description: Text("Find Core Values, Milestones, Actions, and Habits by name.")
        )
    }

    private var noResults: some View {
        ContentUnavailableView.search(text: query)
    }

    private var resultsList: some View {
        List {
            let grouped = Dictionary(grouping: results, by: \.category)
            let order = ["Core Values", "Milestones", "Actions", "Habits"]
            ForEach(order, id: \.self) { category in
                if let items = grouped[category], !items.isEmpty {
                    Section {
                        ForEach(items) { result in
                            SearchResultRow(result: result)
                        }
                    } header: {
                        Text(category).sectionHeaderStyle()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Result Row

private struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        switch result {
        case .coreValue(let value):
            NavigationLink(value: value) {
                rowContent
            }
        case .milestone(let milestone):
            NavigationLink(value: milestone) {
                rowContent
            }
        case .action(let action):
            ActionSearchRow(action: action)
        case .habit(let habit):
            NavigationLink(value: habit) {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(result.title)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            if !result.subtitle.isEmpty {
                Text(result.subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }
}

// Actions are not NavigationLink targets in the search context — we show them inline.
private struct ActionSearchRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var action: Action
    @State private var actionToEdit: Action?

    var body: some View {
        HStack(alignment: .center) {
            ActionItemCheckBox(action: action)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(action.name)
                    .font(AppTheme.Typography.callout)
                    .strikethrough(action.done)
                    .foregroundStyle(action.done ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                    .lineLimit(3)
                if let due = action.due {
                    Text(due.formatted(date: .numeric, time: .omitted))
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(action.pastDue ? AppTheme.Colors.warning : AppTheme.Colors.textSecondary)
                } else if let ms = action.milestone {
                    Text(ms.name)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                withAnimation { action.toggle() }
            } label: {
                action.done ? Text("Mark\nIncomplete") : Text("Mark\nComplete")
            }
            .tint(action.done ? .gray : .green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                context.delete(action)
            } label: {
                Text("Delete")
            }
            Button {
                actionToEdit = action
            } label: {
                Text("Edit")
            }
            .tint(.gray)
        }
        .sheet(item: $actionToEdit) { a in
            EditActionView(action: a)
        }
    }
}

// MARK: - Previews

#Preview("Search") {
    do {
        let previewer = try Previewer()
        return SearchView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}
