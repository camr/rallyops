//
//  HabitTests.swift
//  rallyopsTests
//

import XCTest
@testable import rallyops

final class HabitTests: XCTestCase {

    // MARK: - doToday

    // doToday indexes into days using: days[Date.now.weekday % 7]
    // Date.weekday = (rawWeekday - firstWeekday + 7) % 7 + 1  (range: 1...7)
    // So days[weekday % 7] maps: weekday 7 → index 0, weekday 1 → index 1, ...
    //
    // To make tests stable regardless of the current calendar locale and day,
    // we compute what index is active today and set exactly that slot to true.

    func testDoToday_scheduledForTodaysSlot_returnsTrue() {
        let todayIndex = todayDaysIndex()
        var days = [Bool](repeating: false, count: 7)
        days[todayIndex] = true

        let habit = Habit("Daily", days: days)

        XCTAssertTrue(habit.doToday)
    }

    func testDoToday_notScheduledForTodaysSlot_returnsFalse() {
        let todayIndex = todayDaysIndex()
        var days = [Bool](repeating: true, count: 7)
        days[todayIndex] = false

        let habit = Habit("Skip today", days: days)

        XCTAssertFalse(habit.doToday)
    }

    func testDoToday_allDaysTrue_returnsTrue() {
        let habit = Habit("Every day", days: [true, true, true, true, true, true, true])

        XCTAssertTrue(habit.doToday)
    }

    func testDoToday_allDaysFalse_returnsFalse() {
        let habit = Habit("Never", days: [false, false, false, false, false, false, false])

        XCTAssertFalse(habit.doToday)
    }

    func testDoToday_onlyOneDayTrue_matchesTodayCorrectly() {
        // Build all 7 variants and check that exactly one of them returns true for today.
        let truthyHabits = (0..<7).filter { index in
            var days = [Bool](repeating: false, count: 7)
            days[index] = true
            return Habit("Test \(index)", days: days).doToday
        }

        XCTAssertEqual(truthyHabits.count, 1,
                       "Exactly one single-day schedule should match today")
        XCTAssertEqual(truthyHabits.first, todayDaysIndex(),
                       "The matching index should be today's days index")
    }

    // MARK: - shiftedDays

    // shiftedDays rotates the raw `days` array so index 0 corresponds to the
    // locale's first weekday.  The rotation start is (firstWeekday - 1) in
    // Swift Calendar's 1-indexed, Sunday-first weekday numbering.

    func testShiftedDays_hasSameCountAsInput() {
        let habit = Habit("Count check", days: [true, false, true, false, true, false, true])

        XCTAssertEqual(habit.shiftedDays.count, 7)
    }

    func testShiftedDays_containsSameTrueCount() {
        let days = [true, false, false, true, false, true, false]
        let habit = Habit("Sum check", days: days)

        let originalTrueCount = days.filter { $0 }.count
        let shiftedTrueCount = habit.shiftedDays.filter { $0 }.count

        XCTAssertEqual(shiftedTrueCount, originalTrueCount)
    }

    func testShiftedDays_allTrue_remainsAllTrue() {
        let habit = Habit("All true", days: [true, true, true, true, true, true, true])

        XCTAssertEqual(habit.shiftedDays, [true, true, true, true, true, true, true])
    }

    func testShiftedDays_allFalse_remainsAllFalse() {
        let habit = Habit("All false", days: [false, false, false, false, false, false, false])

        XCTAssertEqual(habit.shiftedDays, [false, false, false, false, false, false, false])
    }

    func testShiftedDays_firstIndexMatchesFirstWeekday() {
        // The first element of shiftedDays should be days[firstWeekday - 1]
        // (firstWeekday is 1-indexed: 1 = Sunday in Swift Calendar).
        let days = [true, false, true, false, true, false, true] // alternating
        let habit = Habit("Alternating", days: days)

        let firstWeekday = Calendar.current.firstWeekday // 1=Sun, 2=Mon, …
        let expectedFirst = days[firstWeekday - 1]

        XCTAssertEqual(habit.shiftedDays.first, expectedFirst)
    }

    func testShiftedDays_lastIndexMatchesDayBeforeFirstWeekday() {
        // The last element of shiftedDays should be days[(firstWeekday - 2 + 7) % 7]
        let days = [true, false, true, false, true, false, true] // alternating
        let habit = Habit("Alternating", days: days)

        let firstWeekday = Calendar.current.firstWeekday
        let expectedLast = days[(firstWeekday - 2 + 7) % 7]

        XCTAssertEqual(habit.shiftedDays.last, expectedLast)
    }

    func testShiftedDays_rotationIsConsistentWithCalendarFirstWeekday() {
        // Build a unique pattern so each position is identifiable.
        // days[i] == true iff i is even (0,2,4,6).
        let days: [Bool] = [true, false, true, false, true, false, true]
        let habit = Habit("Pattern", days: days)

        let firstWeekday = Calendar.current.firstWeekday // 1-indexed, Sunday = 1
        let shiftStart = firstWeekday - 1                // 0-indexed

        // Manually compute expected shifted array
        let expected = Array(days[shiftStart...]) + Array(days[..<shiftStart])

        XCTAssertEqual(habit.shiftedDays, expected)
    }

    func testShiftedDays_sundayFirstCalendar_noRotationForSundayStart() {
        // If the locale's first weekday IS Sunday (index 0 in our days array),
        // shiftedDays should equal the original days array unchanged.
        // We only assert this when Calendar.current.firstWeekday == 1 (Sunday).
        guard Calendar.current.firstWeekday == 1 else {
            // Locale starts on Monday or another day — skip this assertion.
            return
        }

        let days = [true, false, true, false, false, false, true]
        let habit = Habit("Sunday start", days: days)

        XCTAssertEqual(habit.shiftedDays, days)
    }

    func testShiftedDays_mondayFirstCalendar_shiftsOneDayLeft() {
        // If locale starts on Monday (firstWeekday == 2 in Swift Calendar),
        // days[0] (Sunday) should appear at the end of shiftedDays.
        guard Calendar.current.firstWeekday == 2 else {
            // Locale does not start on Monday — skip this assertion.
            return
        }

        let days = [true, false, false, false, false, false, false] // Only Sunday true
        let habit = Habit("Monday start", days: days)

        // After a left-by-1 rotation, Sunday (originally index 0) should be last.
        XCTAssertEqual(habit.shiftedDays.last, true)
        XCTAssertEqual(habit.shiftedDays.first, false) // Monday should be first
    }

    // MARK: - Helpers

    /// Returns the index into the `days` array that `doToday` reads.
    ///
    /// doToday reads `days[Date.now.weekday % 7]`
    /// where Date.weekday = (rawWeekday - firstWeekday + 7) % 7 + 1  (1...7)
    private func todayDaysIndex() -> Int {
        let cal = Calendar.current
        let rawWeekday = cal.component(.weekday, from: Date.now)   // 1=Sun … 7=Sat
        let firstWeekday = cal.firstWeekday                        // 1=Sun, 2=Mon …
        let weekday = (rawWeekday - firstWeekday + 7) % 7 + 1     // 1…7
        return weekday % 7                                         // 0…6
    }
}
