//
//  CreateMilestoneValidatorTests.swift
//  rallyopsTests
//

import SwiftData
import XCTest
@testable import rallyops

@MainActor
final class CreateMilestoneValidatorTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var coreValue: CoreValue!
    private let validator = CreateMilestoneValidator()

    override func setUpWithError() throws {
        let schema = Schema([
            CoreValue.self,
            Milestone.self,
            Action.self,
            Habit.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, migrationPlan: MigrationPlan.self, configurations: [config])
        context = container.mainContext
        coreValue = CoreValue("Test Core Value")
        context.insert(coreValue)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        coreValue = nil
    }

    // MARK: - Valid milestone

    func testValidate_validMilestone_doesNotThrow() throws {
        let futureDate = Date.now.advanced(by: 86400) // 1 day from now
        let milestone = Milestone("Valid milestone", deadline: futureDate)
        milestone.core_value = coreValue
        context.insert(milestone)

        XCTAssertNoThrow(try validator.validate(milestone))
    }

    // MARK: - Invalid name

    func testValidate_emptyName_throwsInvalidName() throws {
        let futureDate = Date.now.advanced(by: 86400)
        let milestone = Milestone("", deadline: futureDate)
        milestone.core_value = coreValue
        context.insert(milestone)

        do {
            try validator.validate(milestone)
            XCTFail("Expected CreateMilestoneError.invalidName to be thrown")
        } catch CreateMilestoneValidator.CreateMilestoneError.invalidName {
            // Expected
        }
    }

    // MARK: - Invalid core value

    func testValidate_nilCoreValue_throwsInvalidCoreValue() throws {
        let futureDate = Date.now.advanced(by: 86400)
        let milestone = Milestone("Valid name", deadline: futureDate)
        milestone.core_value = nil
        context.insert(milestone)

        do {
            try validator.validate(milestone)
            XCTFail("Expected CreateMilestoneError.invalidCoreValue to be thrown")
        } catch CreateMilestoneValidator.CreateMilestoneError.invalidCoreValue {
            // Expected
        }
    }

    // MARK: - Invalid deadline

    func testValidate_pastDeadline_throwsInvalidDeadline() throws {
        let pastDate = Date.now.advanced(by: -86400) // 1 day ago
        let milestone = Milestone("Valid name", deadline: pastDate)
        milestone.core_value = coreValue
        context.insert(milestone)

        do {
            try validator.validate(milestone)
            XCTFail("Expected CreateMilestoneError.invalidDeadline to be thrown")
        } catch CreateMilestoneValidator.CreateMilestoneError.invalidDeadline {
            // Expected
        }
    }

    func testValidate_deadlineExactlyNow_throwsInvalidDeadline() throws {
        let milestone = Milestone("Valid name", deadline: Date.now)
        milestone.core_value = coreValue
        context.insert(milestone)

        do {
            try validator.validate(milestone)
            XCTFail("Expected CreateMilestoneError.invalidDeadline to be thrown")
        } catch CreateMilestoneValidator.CreateMilestoneError.invalidDeadline {
            // Expected
        }
    }

    // MARK: - Error descriptions

    func testErrorDescription_invalidName_returnsExpectedMessage() {
        let error = CreateMilestoneValidator.CreateMilestoneError.invalidName
        XCTAssertEqual(error.errorDescription, "The milestone must have a valid name")
    }

    func testErrorDescription_invalidCoreValue_returnsExpectedMessage() {
        let error = CreateMilestoneValidator.CreateMilestoneError.invalidCoreValue
        XCTAssertEqual(error.errorDescription, "The milestone must be associated with a Core Value")
    }

    func testErrorDescription_invalidDeadline_returnsExpectedMessage() {
        let error = CreateMilestoneValidator.CreateMilestoneError.invalidDeadline
        XCTAssertEqual(error.errorDescription, "The milestone must have a deadline in the future")
    }
}
