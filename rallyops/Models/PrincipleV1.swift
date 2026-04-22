//
//  Principle.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/19/24.
//

import SwiftUI
import SwiftData

extension Calendar {
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)

    func weekBoundary(for date: Date = Date()) -> WeekBoundary? {
        guard let weekInterval = Self.autoupdatingCurrent.dateInterval(
            of: .weekOfYear, for: date) else { return nil }

        return (weekInterval.start, weekInterval.end)
    }
}

extension Date {
    var calendar: Calendar { Calendar.autoupdatingCurrent }

    var weekday: Int {
        (calendar.component(.weekday, from: self) - calendar.firstWeekday + 7) % 7 + 1
    }

    static var weekSymbols: [String] {
        let firstWeekday = Calendar.current.firstWeekday
        var symbols = Calendar.current.veryShortWeekdaySymbols
        symbols = Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]

        return symbols
    }

    var short: String {
        DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
    }
}

enum PrincipleV1Schema: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [CoreValue.self] }

    @Model
    final class CoreValue {
        var name: String
        var details: String
        var createdAt: Date

        @Relationship(deleteRule: .cascade, inverse: \Milestone.core_value)
        var milestones = [Milestone]()

        @Relationship(deleteRule: .cascade, inverse: \Action.core_value)
        var actions = [Action]()

        @Relationship(deleteRule: .cascade, inverse: \Habit.core_value)
        var habits = [Habit]()

        init(_ name: String = "", createdAt: Date = .now) {
            self.name = name
            self.details = ""
            self.createdAt = createdAt
        }

        func addMilestone(_ milestone: Milestone) {
            self.milestones.append(milestone)
        }

        func addAction(_ action: Action) {
            self.actions.append(action)
        }

        func addHabit(_ habit: Habit) {
            self.habits.append(habit)
        }
    }

    @Model
    final class Milestone {
        var name: String
        var deadline: Date
        var complete: Bool

        var core_value: CoreValue?

        @Relationship(deleteRule: .cascade, inverse: \Action.milestone)
        var actions = [Action]()

        @Relationship(deleteRule: .cascade, inverse: \Habit.milestone)
        var habits = [Habit]()

        init(_ name: String, deadline: Date) {
            self.name = name
            self.complete = false
            self.deadline = deadline
            self.actions = actions
            self.habits = habits
        }

        func addAction(_ action: Action) {
            self.actions.append(action)
        }

        func addHabit(_ habit: Habit) {
            self.habits.append(habit)
        }

        func toggle() {
            self.complete.toggle()
        }
    }

    @Model
    final class Action {
        var name: String
        var due: Date?
        var done: Bool
        var doneDate: Date?

        var milestone: Milestone?
        var core_value: CoreValue?

        init(_ name: String, due: Date? = nil, milestone: Milestone? = nil) {
            self.name = name
            self.done = false
            self.due = due
            self.milestone = milestone
        }

        @Transient
        var pastDue: Bool {
            if let due = self.due {
                return Calendar.current.compare(due, to: Date.now, toGranularity: .day) == .orderedAscending
            }
            return false
        }

        func toggle() {
            if !done {
                done = true
                doneDate = Date.now
            } else {
                done = false
                doneDate = nil
            }
        }
    }

    @Model
    final class Habit {
        var name: String = ""
        var days: [Bool] = []
        var time: Int = -1 // Minutes since 00:00

        var milestone: Milestone?
        var core_value: CoreValue?

        @Relationship(deleteRule: .cascade, inverse: \CheckIn.habit)
        var checkins = [CheckIn]()

        init(
            _ name: String,
            milestone: Milestone? = nil,
            days: [Bool] = [false, false, false, false, false, false, false],
            time: Int = -1
        ) {
            self.name = name
            self.milestone = milestone
            self.days = days
            self.time = time
            self.checkins = []
        }

        @Transient
        var doToday: Bool {
            let weekday = Date.now.weekday
            return self.days[weekday % 7]
        }

        @Transient
        var shiftedDays: [Bool] {
            let firstWeekday = Calendar.current.firstWeekday
            return Array(self.days[firstWeekday-1..<self.days.count]) + self.days[0..<firstWeekday-1]
        }

        @Transient
        var timeDisplay: String {
            if time < 0 {
                return ""
            }

            let components = DateComponents(hour: time / 60, minute: time % 60)
            if let date = Calendar.current.date(from: components) {
                return date.formatted(date: .omitted, time: .shortened)
            }

            return ""
        }

        func hasCheckedIn(date: Date = Date.now) -> Bool {
            return self.checkins.contains(where: { checkin in
                Calendar.current.compare(checkin.date, to: date, toGranularity: .day) == .orderedSame
            })
        }

        func toggleCheckin(date: Date = Date.now) {
            if let existing = self.checkins.firstIndex(where: { checkin in
                Calendar.current.compare(checkin.date, to: date, toGranularity: .day) == .orderedSame
            }) {
                self.checkins.remove(at: existing)
            } else {
                self.checkins.append(CheckIn(habit: self, date: date))
            }
        }

        func removeCheckin(date: Date?) -> CheckIn? {
            let checkin = self.checkins.first {
                Calendar.current.isDate($0.date, inSameDayAs: date ?? Date.now)
            }

            if checkin != nil {
                return checkin
            }

            return nil
        }

        @Transient
        var currentStreak: Int {
            let cal = Calendar.current
            var streak = 0
            var date = Date.now
            for _ in 0..<365 {
                let shouldDo = shiftedDays[date.weekday - 1]
                if shouldDo {
                    if hasCheckedIn(date: date) {
                        streak += 1
                    } else if !cal.isDateInToday(date) {
                        // Past scheduled day with no check-in — streak is broken.
                        break
                    }
                    // Today is scheduled but not yet checked in — don't count it,
                    // but don't break the streak either.
                }
                guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            }
            return streak
        }
    }

    @Model
    final class CheckIn {
        var date: Date
        var habit: Habit?

        init(habit: Habit, date: Date) {
            self.habit = habit
            self.date = date
        }
    }
}
