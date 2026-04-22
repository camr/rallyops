//
//  EditMilestoneView.swift
//  rallyops
//

import SwiftUI
import SwiftData

struct EditMilestoneView: View {
    @Environment(\.dismiss) var dismiss

    @Bindable var milestone: Milestone

    @Query(sort: \CoreValue.name) private var values: [CoreValue]

    @State private var hasError = false
    @State private var error: CreateMilestoneValidator.CreateMilestoneError?

    private let validator = CreateMilestoneValidator()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $milestone.name)
                        .accessibilityIdentifier("milestone-edit-name-field")

                    Picker("Core Value", selection: $milestone.core_value) {
                        Text("Select Core Value").tag(nil as CoreValue?)
                        Divider()
                        ForEach(values, id: \.self) { value in
                            Text(value.name).tag(value as CoreValue?)
                        }
                    }
                    .pickerStyle(.menu)

                    DatePicker("Deadline", selection: $milestone.deadline, displayedComponents: [.date])
                        .accessibilityIdentifier("milestone-edit-deadline-picker")
                } footer: {
                    if let err = error {
                        Text(err.errorDescription ?? "")
                            .foregroundStyle(.red)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("milestone-edit-save-button")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Milestone")
        }
    }

    private func save() {
        do {
            try validator.validateForEdit(milestone)
            dismiss()
        } catch let validationError as CreateMilestoneValidator.CreateMilestoneError {
            self.error = validationError
            hasError = true
        } catch {
            self.error = nil
            hasError = true
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        let milestone = try previewer.container.mainContext.fetch(Milestone.withActionAndHabit).first!
        return EditMilestoneView(milestone: milestone)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to load preview")
    }
}
