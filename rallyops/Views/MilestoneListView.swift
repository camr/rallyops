//
//  RallyOpsListView.swift
//  rallyops
//
//  Created by Cameron Rivers on 4/8/24.
//

import SwiftUI
import SwiftData

enum MilestoneBrowseMode: String, CaseIterable, Identifiable {
    case byCoreValue = "By Value"
    case byDate = "By Date"

    var id: String { rawValue }
}

// MARK: Milestone List
struct MilestonesByCoreValueListView: View {
    @Query(sort: \CoreValue.name) private var values: [CoreValue]

    @State private var showingCreateMilestone: Bool = false
    @State private var browseMode: MilestoneBrowseMode = .byCoreValue

    var body: some View {
        NavigationStack {
            Group {
                if browseMode == .byCoreValue {
                    MilestonesGroupedByCoreValueContent(
                        values: values,
                        showingCreateMilestone: $showingCreateMilestone
                    )
                } else {
                    MilestonesByDateView(showingCreateMilestone: $showingCreateMilestone)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Picker("Browse Mode", selection: $browseMode) {
                    ForEach(MilestoneBrowseMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(Color(UIColor.systemGroupedBackground))
                .accessibilityLabel("Milestone filter")
                .accessibilityIdentifier(browseMode == .byCoreValue ? "milestone-filter-by-value-button" : "milestone-filter-by-date-button")
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Create Milestone", systemImage: "plus") {
                        showingCreateMilestone.toggle()
                    }
                    .accessibilityLabel("Create Milestone")
                    .accessibilityIdentifier("milestone-add-button")
                }
            }
            .navigationTitle("Milestones")
            .navigationDestination(for: Milestone.self) { milestone in
                MilestoneView(milestone: milestone)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
        }
        .fullScreenCover(isPresented: $showingCreateMilestone) {
            CreateMilestoneView()
        }
    }
}

private struct MilestonesGroupedByCoreValueContent: View {
    let values: [CoreValue]
    @Binding var showingCreateMilestone: Bool

    var body: some View {
        List(values) { value in
            Section {
                if value.milestones.isEmpty {
                    ContentUnavailableView {
                        Label("No Milestones", systemImage: "nosign")
                    } description: {
                        Text("Create a milestone to start on your \(value.name) journey.")
                    } actions: {
                        Button("Create Milestone") {
                            showingCreateMilestone = true
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Create milestone for \(value.name)")
                    }
                } else {
                    ForEach(value.milestones.sortByDate()) { milestone in
                        NavigationLink(value: milestone) {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(milestone.name)
                                    .font(AppTheme.Typography.headline)
                                    .strikethrough(milestone.complete)
                                    .foregroundStyle(
                                        milestone.complete
                                            ? AppTheme.Colors.textSecondary
                                            : AppTheme.Colors.textPrimary
                                    )
                                Text(milestone.deadline.formatted(date: .abbreviated, time: .omitted))
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                        }
                        .accessibilityIdentifier("milestone-row-\(milestone.id)")
                        .accessibilityLabel(
                            "\(milestone.name), due \(milestone.deadline.formatted(date: .abbreviated, time: .omitted))\(milestone.complete ? ", completed" : "")"
                        )
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                withAnimation {
                                    milestone.toggle()
                                }
                            } label: {
                                if milestone.complete {
                                    Text("Mark\nIncomplete")
                                } else {
                                    Text("Mark\nComplete")
                                }
                            }
                            .tint(milestone.complete ? .gray : .green)
                            .accessibilityLabel(milestone.complete ? "Mark \(milestone.name) incomplete" : "Mark \(milestone.name) complete")
                        }
                    }
                }
            } header: {
                Text(value.name)
                    .sectionHeaderStyle()
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("milestones-list")
    }
}

struct MilestonesByDateView: View {
    @Query(sort: \Milestone.deadline) private var milestones: [Milestone]
    @Binding var showingCreateMilestone: Bool

    init(showingCreateMilestone: Binding<Bool> = .constant(false)) {
        self._showingCreateMilestone = showingCreateMilestone
    }

    var body: some View {
        Group {
            if milestones.isEmpty {
                ContentUnavailableView {
                    Label("No Milestones", systemImage: "nosign")
                } description: {
                    Text("Create a milestone to start tracking progress by deadline.")
                } actions: {
                    Button("Create Milestone") {
                        showingCreateMilestone = true
                    }
                    .buttonStyle(.bordered)
                }
            } else {
            List(milestones) { stone in
                NavigationLink(value: stone) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stone.name)
                            .strikethrough(stone.complete)
                            .foregroundStyle(
                                stone.complete
                                    ? AppTheme.Colors.textSecondary
                                    : AppTheme.Colors.textPrimary
                            )

                        Text(stone.deadline.formatted(date: .numeric, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 12)

                        Text(stone.core_value?.name ?? "No Values?")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.accent)
                    }
                }
                .accessibilityIdentifier("milestone-row-\(stone.id)")
                .accessibilityLabel(
                    "\(stone.name), due \(stone.deadline.formatted(date: .numeric, time: .omitted)), \(stone.core_value?.name ?? "no core value")\(stone.complete ? ", completed" : "")"
                )
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        withAnimation {
                            stone.toggle()
                        }
                    } label: {
                        if stone.complete {
                            Text("Mark\nIncomplete")
                        } else {
                            Text("Mark\nComplete")
                        }
                    }
                    .tint(stone.complete ? .gray : .green)
                    .accessibilityLabel(stone.complete ? "Mark \(stone.name) incomplete" : "Mark \(stone.name) complete")
                }
            }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilityIdentifier("milestones-list")
    }
}

// MARK: Single Milestone
struct MilestoneView: View {
    @Bindable var milestone: Milestone

    @State var createNew: Bool = false
    @State var showingEdit: Bool = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    let date = Text(milestone.deadline.formatted(date: .long, time: .omitted))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    let label = Text("Next Check-in:")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Text("\(label) \(date)")
                }
                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.md, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.md))
            }

            if milestone.actions.isEmpty && milestone.habits.isEmpty {
                ContentUnavailableView {
                    Label("No Actions", systemImage: "nosign")
                } description: {
                    Text("Actions and Habits for this milestone will appear here.")
                } actions: {
                    Button("Create New Action or Habit") {
                        createNew = true
                    }
                }
            } else {
                if !milestone.actions.isEmpty {
                    Section {
                        ActionItemsListView(actions: milestone.actions)
                    } header: {
                        Text("Actions").sectionHeaderStyle()
                    }
                }

                if !milestone.habits.isEmpty {
                    Section {
                        HabitListView(habits: milestone.habits)
                    } header: {
                        Text("Habits").sectionHeaderStyle()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(milestone.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    withAnimation {
                        milestone.toggle()
                    }
                } label: {
                    if milestone.complete {
                        Label("Mark Incomplete", systemImage: "circle")
                    } else {
                        Label("Mark Complete", systemImage: "checkmark.circle")
                    }
                }
                .accessibilityLabel(milestone.complete ? "Mark \(milestone.name) incomplete" : "Mark \(milestone.name) complete")

                Button {
                    showingEdit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .accessibilityLabel("Edit \(milestone.name)")

                Button {
                    createNew = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .accessibilityLabel("Add action or habit to \(milestone.name)")
                .accessibilityIdentifier("milestone-add-action-habit-button")
            }
        }
        .sheet(isPresented: $createNew, onDismiss: { createNew = false }) {
            CreateActionOrHabitSheet(milestone: milestone)
        }
        .sheet(isPresented: $showingEdit, onDismiss: { showingEdit = false }) {
            EditMilestoneView(milestone: milestone)
        }
    }
}

// MARK: Create Action or Habit
enum ItemToAdd {
    case action
    case habit
}
struct CreateActionOrHabitSheet: View {
    @Environment(\.presentationMode) var presentationMode

    let milestone: Milestone

    @State var itemType: ItemToAdd = .habit
    @State var showCancelConfirmation: Bool = false

    @State var action: Action
    @State var habit: Habit
    @State private var habitDraft = HabitDraft(name: "", days: [Bool](repeating: false, count: 7), time: -1)

    init(milestone: Milestone) {
        self.milestone = milestone
        self.action = Action("", due: Date())
        self.habit = Habit("")
    }

    private var isAddValid: Bool {
        if itemType == .action {
            return !action.name.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            let nameValid = !habitDraft.name.trimmingCharacters(in: .whitespaces).isEmpty
            let daysValid = habitDraft.days.contains(true)
            return nameValid && daysValid
        }
    }

    private var addButtonHint: String {
        guard itemType == .habit else { return "" }
        let nameValid = !habitDraft.name.trimmingCharacters(in: .whitespaces).isEmpty
        let daysValid = habitDraft.days.contains(true)
        if !nameValid { return "Enter a habit name to add" }
        if !daysValid { return "Select at least one day to add" }
        return ""
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text(milestone.name)
                    .font(.title2)
                    .padding(.top)

                Picker("Type of thing", selection: $itemType) {
                    Text("Action Item").tag(ItemToAdd.action)
                    Text("Habit").tag(ItemToAdd.habit)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .accessibilityIdentifier("create-item-type-picker")

                if itemType == .action {
                    ActionItemEditFields(action: action, canSetMilestone: false)
                } else {
                    HabitEditFields(habit: habit, canSetMilestone: false, isCreating: true) { newDraft in
                        habitDraft = newDraft
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if action.name != "" {
                            showCancelConfirmation = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Cancel")
                    }
                    .accessibilityIdentifier("habit-create-cancel-button")
                    .confirmationDialog("Cancel",
                                        isPresented: $showCancelConfirmation) {
                        Button("Discard Changes", role: .destructive) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        Button("Continue Editing", role: .cancel) {
                            showCancelConfirmation = false
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if itemType == .action {
                            milestone.addAction(action)
                        } else if itemType == .habit {
                            habit.name = habitDraft.name
                            applyHabitDays(habitDraft.days, to: habit)
                            habit.time = habitDraft.time
                            milestone.addHabit(habit)
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!isAddValid)
                    .accessibilityHint(addButtonHint)
                    .accessibilityIdentifier(itemType == .habit ? "habit-create-save-button" : "action-create-save-button")
                }
            }
            .navigationTitle("Add to Milestone")
//            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: Previews
#Preview("Milestones by Core Value") {
    do {
        let previewer = try Previewer()
        return MilestonesByCoreValueListView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Milestones by Date") {
    do {
        let previewer = try Previewer()
        return NavigationStack {
            MilestonesByDateView()
        }
        .modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Milestone") {
    do {
        let previewer = try Previewer()
        let sample = try previewer.container.mainContext.fetch(Milestone.withActionAndHabit).first

        return NavigationStack {
            MilestoneView(milestone: sample!)
        }
        .modelContainer(previewer.container)

    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Add to Milestone") {
    do {
        let previewer = try Previewer()
        let sample = try previewer.container.mainContext.fetch(Milestone.withActionAndHabit).first

        return Group {
            CreateActionOrHabitSheet(milestone: sample!)
        }
        .modelContainer(previewer.container)

    } catch {
        return Text("Failed to load Preview")
    }
}
