//
//  ActionItem.swift
//  rallyops
//
//  Created by Cameron Rivers on 4/9/24.
//

import SwiftUI
import SwiftData

struct ActionItemsListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.appAccentColor) var accentColor

    @State var actionToEdit: Action?

    let actions: [Action]

    var body: some View {
        ForEach(actions) { action in
            HStack(alignment: .center) {
                ActionItemCheckBox(action: action)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(action.name)
                        .font(AppTheme.Typography.callout)
                        .strikethrough(action.done)
                        .foregroundStyle(action.done ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                        .lineLimit(3)

                    if action.milestone != nil || action.due != nil {
                        let isToday = action.due.map { Calendar.current.isDateInToday($0) } ?? false
                        let isOverdue = action.pastDue && !action.done
                        HStack(spacing: 4) {
                            if action.milestone != nil {
                                Text("HIGH PRIORITY")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(accentColor)
                                Text("·")
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                            if let due = action.due {
                                let label = isToday ? "DUE TODAY" : (isOverdue ? "OVERDUE" : "DUE \(due.formatted(date: .abbreviated, time: .omitted))")
                                Text(label)
                                    .foregroundStyle(isOverdue ? AppTheme.Colors.warning : AppTheme.Colors.textSecondary)
                            }
                        }
                        .font(AppTheme.Typography.caption)
                    }
                }
            }
            .contentShape(Rectangle())
            .accessibilityIdentifier("action-row-\(action.name)")
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    withAnimation {
                        action.toggle()
                    }
                } label: {
                    if action.done {
                        Text("Mark\nIncomplete")
                    } else {
                        Text("Mark\nComplete")
                    }
                }
                .tint(action.done ? .gray : .green)
                .accessibilityLabel(action.done ? "Mark \(action.name) incomplete" : "Mark \(action.name) complete")
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    context.delete(action)
                } label: {
                    Text("Delete")
                }
                .tint(.red)
                .accessibilityLabel("Delete \(action.name)")

                Button {
                    actionToEdit = action
                } label: {
                    Text("Edit")
                }
                .tint(.gray)
                .accessibilityLabel("Edit \(action.name)")

            }
            .accessibilityElement(children: .contain)
            .padding(.vertical, 1)
            .listRowBackground(
                Group {
                    if #available(iOS 26, *) {
                        Color.clear
                            .glassEffect(in: RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                    } else {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .fill(.ultraThinMaterial)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                    }
                }
            )
        }

        .sheet(item: $actionToEdit) { action in
            EditActionView(action: action)
        }
    }
}

struct ActionItemCheckBox: View {
    @Environment(\.appAccentColor) var accentColor
    let action: Action

    let size: CGFloat = 20

    var body: some View {
        Button {
            withAnimation {
                action.toggle()
            }
        } label: {
            Circle()
                .fill(action.done ? accentColor : Color.clear)
                .stroke(AppTheme.Colors.textPrimary.opacity(0.5), lineWidth: action.done ? 0 : 1)
                .frame(width: size, height: size)
                .padding(.vertical, 4)
                .padding(.trailing, 4)
                .overlay {
                    Circle()
                        .stroke(accentColor, lineWidth: 1)
                        .frame(width: size + 4, height: size + 4)
                        .offset(x: -2)
                        .opacity(action.done ? 1.0 : 0.0)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.done ? "Mark \(action.name) incomplete" : "Mark \(action.name) complete")
        .accessibilityHint(action.done ? "Tap to uncheck this action" : "Tap to mark this action as done")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("action-checkbox-\(action.name)")
    }
}

public func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct ActionItemEditFields: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Milestone.name) private var milestones: [Milestone]

    @Bindable var action: Action

    @State var canSetMilestone: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            TextField("Action Item", text: $action.name)
                .padding()
                .background(Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 10)))
                .font(.headline)
                .padding(.vertical, 32)
                .accessibilityIdentifier("action-create-name-field")

            if canSetMilestone {
                Section {
                    HStack {
                        Text("Milestone:").padding(.leading, 10)
                        Spacer()
                        Picker("Milestone", selection: $action.milestone) {
                            Text("No Milestone Selected").tag(nil as Milestone?)
                            Divider()
                            ForEach(milestones) { milestone in
                                Text(milestone.name).tag(milestone)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }

            HStack {
                Image(systemName: "calendar")

                DatePicker("Due Date",
                           selection: $action.due ?? Date(),
                           displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .accessibilityIdentifier("action-create-due-date-picker")
            }
            .padding(.vertical, 4)
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.separator)
            }

            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct EditActionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode

    @Bindable var action: Action

    @Query(sort: \Milestone.name) private var milestones: [Milestone]

    @State private var initialActionName: String = ""
    @State private var initialActionDate: Date?
    @State private var initialMilestoneName: String = ""
    @State private var showCancelConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            ActionItemEditFields(action: action)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Edit Action")
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            if hasChanges {
                                showCancelConfirmation = true
                            } else {
                                cancel()
                            }
                        } label: {
                            Text("Cancel")
                        }
                        .accessibilityIdentifier("action-create-cancel-button")
                        .confirmationDialog("Cancel",
                                            isPresented: $showCancelConfirmation) {
                            Button("Discard Changes", role: .destructive) { cancel() }
                            Button("Cancel", role: .cancel) { showCancelConfirmation = false }
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Action", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("action-edit-delete-button")
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: save) {
                            Text("Save")
                        }
                        .accessibilityIdentifier("action-create-save-button")
                    }
                }
                .confirmationDialog("Delete Action", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        context.delete(action)
                        presentationMode.wrappedValue.dismiss()
                    }
                    Button("Cancel", role: .cancel) {
                        showDeleteConfirmation = false
                    }
                } message: {
                    Text("Are you sure you want to delete \"\(action.name)\"?")
                }
                .onAppear {
                    initialActionName = action.name
                    initialActionDate = action.due
                    initialMilestoneName = action.milestone?.name ?? ""
                }
        }
    }

    private var hasChanges: Bool {
        action.name != initialActionName ||
        action.due != initialActionDate ||
        action.milestone?.name ?? "" != initialMilestoneName
    }

    func save() {
        // Changes are already persisted via @Bindable action
        // SwiftData auto-saves when context changes
        presentationMode.wrappedValue.dismiss()
    }

    func cancel() {
        // Revert changes
        action.name = initialActionName
        action.due = initialActionDate
        // Note: milestone changes are already applied via binding

        presentationMode.wrappedValue.dismiss()
    }
}

#Preview("Actions List") {
    do {
        let previewer = try Previewer()
        let actions = try previewer.container.mainContext.fetch(Action.allTodo)

        return List {
            Section("Actions") {
                ActionItemsListView(actions: actions)
            }
        }
            .modelContainer(previewer.container)

    } catch {
        return Text("Failed to load Preview")
    }
}
