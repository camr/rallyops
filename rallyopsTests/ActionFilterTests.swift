//
//  ActionFilterTests.swift
//  rallyopsTests
//

import XCTest
@testable import rallyops

final class ActionFilterTests: XCTestCase {

    // MARK: - Basic date matching

    func testFilter_returnsActionsDueOnSelectedDate() {
        let calendar = Calendar.current
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let sameDayMorning = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: selectedDate)!
        let sameDayEvening = calendar.date(bySettingHour: 18, minute: 45, second: 0, of: selectedDate)!
        let otherDay = date(year: 2026, month: 2, day: 16)

        let dueMorning = Action("Morning", due: sameDayMorning)
        let dueEvening = Action("Evening", due: sameDayEvening)
        let dueOtherDay = Action("Other day", due: otherDay)

        let filtered = Action.filter(actions: [dueEvening, dueOtherDay, dueMorning], for: selectedDate)

        XCTAssertEqual(filtered.map(\.name), ["Morning", "Evening"])
    }

    func testFilter_excludesActionsWithoutDueDate() {
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let dueAction = Action("Dated", due: selectedDate)
        let noDueAction = Action("No due date", due: nil)

        let filtered = Action.filter(actions: [noDueAction, dueAction], for: selectedDate)

        XCTAssertEqual(filtered.map(\.name), ["Dated"])
    }

    // MARK: - Edge cases

    func testFilter_emptyInput_returnsEmpty() {
        let selectedDate = date(year: 2026, month: 2, day: 15)

        let filtered = Action.filter(actions: [], for: selectedDate)

        XCTAssertTrue(filtered.isEmpty)
    }

    func testFilter_noActionsMatchDate_returnsEmpty() {
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let wrongDay1 = Action("Wrong day 1", due: date(year: 2026, month: 2, day: 14))
        let wrongDay2 = Action("Wrong day 2", due: date(year: 2026, month: 2, day: 16))

        let filtered = Action.filter(actions: [wrongDay1, wrongDay2], for: selectedDate)

        XCTAssertTrue(filtered.isEmpty)
    }

    func testFilter_allActionsHaveNilDue_returnsEmpty() {
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let a = Action("No due 1", due: nil)
        let b = Action("No due 2", due: nil)

        let filtered = Action.filter(actions: [a, b], for: selectedDate)

        XCTAssertTrue(filtered.isEmpty)
    }

    // MARK: - Sorting

    func testFilter_sortsByDueTimeAscending() {
        let cal = Calendar.current
        let selectedDate = date(year: 2026, month: 3, day: 1)
        let t1 = cal.date(bySettingHour: 7, minute: 0, second: 0, of: selectedDate)!
        let t2 = cal.date(bySettingHour: 12, minute: 0, second: 0, of: selectedDate)!
        let t3 = cal.date(bySettingHour: 23, minute: 59, second: 0, of: selectedDate)!

        let noon   = Action("Noon",       due: t2)
        let late   = Action("Late night", due: t3)
        let early  = Action("Early bird", due: t1)

        let filtered = Action.filter(actions: [noon, late, early], for: selectedDate)

        XCTAssertEqual(filtered.map(\.name), ["Early bird", "Noon", "Late night"])
    }

    func testFilter_singleMatchingAction_returnsThatAction() {
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let match = Action("Only match", due: selectedDate)
        let miss  = Action("Miss",       due: date(year: 2026, month: 2, day: 20))

        let filtered = Action.filter(actions: [miss, match], for: selectedDate)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Only match")
    }

    func testFilter_mixOfNilAndDatedActions_returnsOnlyMatchingDated() {
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let noDue  = Action("No due",    due: nil)
        let match  = Action("Match",     due: selectedDate)
        let noMatch = Action("No match", due: date(year: 2026, month: 2, day: 16))

        let filtered = Action.filter(actions: [noDue, noMatch, match], for: selectedDate)

        XCTAssertEqual(filtered.map(\.name), ["Match"])
    }

    // MARK: - Cross-day boundary

    func testFilter_midnightBoundary_excludesPreviousDay() {
        let cal = Calendar.current
        let selectedDate = date(year: 2026, month: 2, day: 15)
        let endOfPrevDay = cal.date(bySettingHour: 23, minute: 59, second: 59,
                                    of: date(year: 2026, month: 2, day: 14))!
        let startOfDay  = cal.date(bySettingHour: 0, minute: 0, second: 0, of: selectedDate)!

        let prevDay    = Action("Prev day",    due: endOfPrevDay)
        let startOfSelected = Action("Start of selected", due: startOfDay)

        let filtered = Action.filter(actions: [prevDay, startOfSelected], for: selectedDate)

        XCTAssertEqual(filtered.map(\.name), ["Start of selected"])
    }

    // MARK: - Helpers

    private func date(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}
