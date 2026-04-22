//
//  CoreValueViews.swift
//  rallyops
//
//  Created by Cameron Rivers on 4/18/24.
//

import SwiftUI
import SwiftData

struct CoreValuesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.appAccentColor) var accentColor
    @Query(sort: \CoreValue.name) private var values: [CoreValue]
    @State private var showingAddCoreValue = false
    @State private var editingValue: CoreValue?
    @State private var blockedDeleteNames: [String] = []
    @State private var showBlockedDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(values) { value in
                    NavigationLink(value: value) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text(value.name)
                                .font(AppTheme.Typography.headline)
                            Text("\(value.milestones.count) \(value.milestones.count == 1 ? "milestone" : "milestones")")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(value.milestones.count > 0 ? AppTheme.Colors.textSecondary : AppTheme.Colors.warning)
                        }
                    }
                    .accessibilityIdentifier("core-value-row-\(value.id)")
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button("Edit", systemImage: "pencil") {
                            editingValue = value
                        }
                        .tint(accentColor)
                    }
                }
                .onDelete(perform: deleteCoreValues)
            }
            .accessibilityIdentifier("core-values-list")
            .navigationTitle("Core Values")
            .listStyle(.insetGrouped)
            .navigationDestination(for: CoreValue.self) { value in
                CoreValueDetailsView(value: value)
            }
            .navigationDestination(for: Milestone.self) { milestone in
                MilestoneView(milestone: milestone)

            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        showingAddCoreValue = true
                    }
                    .accessibilityIdentifier("core-value-add-button")
                }
            }
            .sheet(isPresented: $showingAddCoreValue) {
                AddCoreValueView()
            }
            .sheet(item: $editingValue) { value in
                EditCoreValueView(value: value)
            }
            .alert("Cannot Delete", isPresented: $showBlockedDeleteAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("These core values have milestones. Remove or reassign their milestones first: \(blockedDeleteNames.joined(separator: ", "))")
            }
        }
    }

    private func deleteCoreValues(at offsets: IndexSet) {
        var toDelete: [Int] = []
        var blocked: [String] = []

        for index in offsets {
            if values[index].milestones.isEmpty {
                toDelete.append(index)
            } else {
                blocked.append(values[index].name)
            }
        }

        for index in toDelete.sorted(by: >) {
            context.delete(values[index])
        }

        if !blocked.isEmpty {
            blockedDeleteNames = blocked
            showBlockedDeleteAlert = true
        }
    }
}

struct CoreValueDetailsView: View {
    let value: CoreValue
    @State private var showingEditCoreValue = false
    @State private var showingAddMilestone = false

    var body: some View {
        List {
            if !value.details.isEmpty {
                Section("Core Value") {
                    Text(value.details)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .accessibilityIdentifier("core-value-detail-view")
            }

            Section("Milestones") {
                if value.milestones.isEmpty {
                    Text("No milestones yet")
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else {
                    ForEach(value.milestones) { milestone in
                        NavigationLink(value: milestone) {
                            Text(milestone.name)
                                .font(AppTheme.Typography.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle(value.name)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Add Milestone", systemImage: "plus") {
                    showingAddMilestone = true
                }
                .accessibilityIdentifier("core-value-add-milestone-button")

                Button("Edit", systemImage: "pencil") {
                    showingEditCoreValue = true
                }
            }
        }
        .sheet(isPresented: $showingEditCoreValue) {
            EditCoreValueView(value: value)
        }
        .fullScreenCover(isPresented: $showingAddMilestone) {
            CreateMilestoneView(preselectedCoreValue: value)
        }
    }
}

struct AddCoreValueView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var details = ""
    @State private var showNameError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .onChange(of: name) { _, _ in
                            showNameError = false
                        }
                        .accessibilityIdentifier("core-value-create-name-field")
                    TextField("Details (optional)", text: $details)
                        .accessibilityIdentifier("core-value-create-description-field")
                } footer: {
                    if showNameError {
                        Text("Name is required")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("core-value-create-validation-error")
                    }
                }
            }
            .navigationTitle("Add Core Value")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("core-value-create-cancel-button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("core-value-create-save-button")
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameError = true
            return
        }
        let value = CoreValue(trimmed)
        value.details = details.trimmingCharacters(in: .whitespaces)
        context.insert(value)
        dismiss()
    }
}

struct EditCoreValueView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var value: CoreValue

    @State private var name: String
    @State private var details: String
    @State private var showNameError = false

    init(value: CoreValue) {
        self.value = value
        _name = State(initialValue: value.name)
        _details = State(initialValue: value.details)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .onChange(of: name) { _, _ in
                            showNameError = false
                        }
                        .accessibilityIdentifier("core-value-edit-name-field")
                    TextField("Details (optional)", text: $details)
                        .accessibilityIdentifier("core-value-edit-description-field")
                } footer: {
                    if showNameError {
                        Text("Name is required")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("core-value-create-validation-error")
                    }
                }
            }
            .navigationTitle("Edit Core Value")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("core-value-edit-save-button")
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showNameError = true
            return
        }

        value.name = trimmedName
        value.details = details.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
}

// MARK: Previews
#Preview("Core Values") {
    do {
        let previewer = try Previewer()
        return CoreValuesView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Add Core Value") {
    do {
        let previewer = try Previewer()
        return AddCoreValueView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Edit Core Value") {
    do {
        let previewer = try Previewer()
        let value = try previewer.container.mainContext.fetch(FetchDescriptor<CoreValue>()).first!
        return EditCoreValueView(value: value).modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}
