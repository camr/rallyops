//
//  DateHelpersTests.swift
//  rallyopsTests
//

import XCTest
@testable import rallyops

final class DateHelpersTests: XCTestCase {

    // MARK: - dateFromString

    func testDateFromString_validFormat_returnsParsedDate() {
        let result = dateFromString("15-06-2024")
        let components = Calendar.current.dateComponents([.day, .month, .year], from: result)

        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.year, 2024)
    }

    func testDateFromString_invalidFormat_returnsDateNow() {
        let before = Date.now
        let result = dateFromString("invalid-date")
        let after = Date.now

        XCTAssertGreaterThanOrEqual(result, before)
        XCTAssertLessThanOrEqual(result, after)
    }

    func testDateFromString_emptyString_returnsDateNow() {
        let before = Date.now
        let result = dateFromString("")
        let after = Date.now

        XCTAssertGreaterThanOrEqual(result, before)
        XCTAssertLessThanOrEqual(result, after)
    }

    func testDateFromString_wrongFormat_returnsDateNow() {
        let before = Date.now
        let result = dateFromString("2024-06-15") // Wrong format: yyyy-mm-dd instead of dd-mm-yyyy
        let after = Date.now

        XCTAssertGreaterThanOrEqual(result, before)
        XCTAssertLessThanOrEqual(result, after)
    }

    // MARK: - until(days:)

    func testUntil_positiveDays_returnsFutureDate() {
        let result = until(days: 7)
        let expected = Date.now.advanced(by: 7 * 24 * 60 * 60)

        XCTAssertEqual(result.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 1)
    }

    func testUntil_negativeDays_returnsPastDate() {
        let result = until(days: -3)
        let expected = Date.now.advanced(by: -3 * 24 * 60 * 60)

        XCTAssertEqual(result.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 1)
    }

    func testUntil_zeroDays_returnsApproximatelyNow() {
        let before = Date.now
        let result = until(days: 0)
        let after = Date.now

        XCTAssertGreaterThanOrEqual(result, before)
        XCTAssertLessThanOrEqual(result, after)
    }
}
