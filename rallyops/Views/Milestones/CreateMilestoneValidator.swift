//
//  CreateMilestoneValidator.swift
//  rallyops
//
//  Created by Cameron Rivers on 6/2/24.
//

import Foundation

/// A validator that ensures a milestone is properly formatted before it can be created.
struct CreateMilestoneValidator {
    /// Validates the given milestone, throwing an error if it's invalid.
    /// - Parameter milestone: The milestone to validate.
    func validate(_ milestone: Milestone) throws {
        try validateForEdit(milestone)
        // Check that the milestone's deadline is in the future.
        guard milestone.deadline >= Date.now else { throw CreateMilestoneError.invalidDeadline }
    }

    /// Validates name and core value for edit (allows past deadlines).
    func validateForEdit(_ milestone: Milestone) throws {
        guard !milestone.name.isEmpty else { throw CreateMilestoneError.invalidName }
        guard milestone.core_value != nil else { throw CreateMilestoneError.invalidCoreValue }
    }
}

// MARK: - Errors
extension CreateMilestoneValidator {
    enum CreateMilestoneError: LocalizedError {
        case invalidCoreValue
        case invalidName
        case invalidDeadline
    }
}

extension CreateMilestoneValidator.CreateMilestoneError {
    var errorDescription: String? {
        switch self {
        case .invalidCoreValue:
            return "The milestone must be associated with a Core Value"
        case .invalidName:
            return "The milestone must have a valid name"
        case .invalidDeadline:
            return "The milestone must have a deadline in the future"
        }
    }
}
