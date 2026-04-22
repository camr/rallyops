//
//  CreateMilestoneView.swift
//  rallyops
//
//  Created by Cameron Rivers on 5/30/24.
//

import SwiftUI
import SwiftData

@Observable
class CreateMilestoneViewModel {
    var milestone = Milestone("", deadline: Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date.now)
    var coreValue: CoreValue?
    var hasError = false

    private let validator = CreateMilestoneValidator()
    private(set) var state: SubmissionState?
    private(set) var error: FormError?

    func create() {
        do {
            guard coreValue != nil else { throw CreateMilestoneValidator.CreateMilestoneError.invalidCoreValue }

            milestone.core_value = coreValue
            try validator.validate(milestone)
            state = .submitting

            self.coreValue!.addMilestone(self.milestone)
            self.state = .successful
        } catch {
            if let validationError = error as? CreateMilestoneValidator.CreateMilestoneError {
                self.error = .validation(error: validationError)
            }

            self.hasError = true
            self.state = .unsuccessful
        }
    }
}

extension CreateMilestoneViewModel {
    enum SubmissionState {
        case submitting
        case successful
        case unsuccessful
    }

    enum FormError: LocalizedError {
        case validation(error: LocalizedError)

        var errorDescription: String? {
            switch self {
            case .validation(let err):
                return err.errorDescription
            }
        }
    }
}

struct CreateMilestoneView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss

    @Query(sort: \CoreValue.name) private var values: [CoreValue]

    @State private var vm = CreateMilestoneViewModel()
    var preselectedCoreValue: CoreValue? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $vm.milestone.name)
                        .accessibilityIdentifier("milestone-create-name-field")

                    Picker("Core Value", selection: $vm.coreValue) {
                        Text("Select Core Value").tag(nil as CoreValue?)
                        Divider()
                        ForEach(values, id: \.self) { value in
                            Text(value.name).tag(value as CoreValue?)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("milestone-create-core-value-picker")

                    DatePicker("Deadline", selection: $vm.milestone.deadline, displayedComponents: [.date])
                        .accessibilityIdentifier("milestone-create-deadline-picker")
                } footer: {
                    if case .validation(let err) = vm.error,
                       let errorDesc = err.errorDescription {
                        Text(errorDesc)
                            .foregroundStyle(.red)
                    }
                }
            }
            .disabled(vm.state == .submitting)
            .onAppear {
                if let preselectedCoreValue {
                    vm.coreValue = preselectedCoreValue
                }
            }

            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        vm.create()
                    }
                    .accessibilityIdentifier("milestone-create-save-button")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("milestone-create-cancel-button")
                }
            }

            .onChange(of: vm.state) {
                if vm.state == .successful {
                    dismiss()
                }
            }

//            .alert(isPresented: $vm.hasError, error: vm.error) { }

            .overlay {
                if vm.state == .submitting {
                    ProgressView()
                }
            }

            .navigationTitle("Create Milestone")
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return CreateMilestoneView()
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to load preview")
    }
}
