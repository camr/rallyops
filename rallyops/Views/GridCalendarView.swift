import SwiftUI
import SwiftData

struct GridCalendarView: View {
    @Environment(\.appAccentColor) var accentColor
    @Binding var showingDate: Date

    @Query(sort: \Action.due) private var actions: [Action]
    @Query var habits: [Habit]

    @AppStorage("settings.startWeekOnMonday") private var startWeekOnMonday = false

    @State private var month: Date
    @State private var selectedDate: Date

    init(showingDate: Binding<Date>) {
        _showingDate = showingDate
        _month = State(initialValue: showingDate.wrappedValue)
        _selectedDate = State(initialValue: showingDate.wrappedValue)
    }

    private var weekCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = startWeekOnMonday ? 2 : 1
        return cal
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.month = self.previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Previous month")
                .accessibilityHint("Navigate to \(previousMonth().formatted(.monthAndYear))")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("calendar-prev-month-button")

                Spacer()
                Text(month.formatted(.monthAndYear))
                    .font(.headline)
                Spacer()

                Button(action: {
                    self.month = self.nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel("Next month")
                .accessibilityHint("Navigate to \(nextMonth().formatted(.monthAndYear))")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("calendar-next-month-button")
            }
            .padding()

            // Day of week headers
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(Array(Date.weekSymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 20)
                        .accessibilityHidden(true)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    let isCurrentMonth = Calendar.current.isDate(date, equalTo: month, toGranularity: .month)
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isToday = Calendar.current.isDateInToday(date)
                    let actionCount = actionCount(on: date)
                    let habitCount = habitCount(on: date)

                    Button(action: {
                        selectedDate = date
                        showingDate = date
                    }) {
                        VStack(spacing: 2) {
                            Text(date.formatted(.day))
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected
                                                ? Color.blue.opacity(0.3)
                                                : Color.clear
                                        )
                                )

                            // Dot indicators for actions and habits (hidden for out-of-month dates)
                            HStack(spacing: 3) {
                                if isCurrentMonth && actionCount > 0 {
                                    Circle()
                                        .fill(accentColor)
                                        .frame(width: 5, height: 5)
                                }
                                if isCurrentMonth && habitCount > 0 {
                                    Circle()
                                        .fill(accentColor.opacity(0.6))
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .opacity(isCurrentMonth ? 1.0 : 0.35)
                    .accessibilityLabel(accessibilityLabel(for: date, isSelected: isSelected, isToday: isToday, actionCount: actionCount, habitCount: habitCount))
                    .accessibilityHint(isSelected ? "" : "Tap to view \(date.formatted(date: .long, time: .omitted))")
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                    .accessibilityIdentifier("calendar-day-cell-\(date.formatted(.iso8601).prefix(10))")
                }
            }
        }
    }

    // MARK: - Accessibility

    private func accessibilityLabel(for date: Date, isSelected: Bool, isToday: Bool, actionCount: Int, habitCount: Int) -> String {
        var parts: [String] = []

        if isToday {
            parts.append("Today,")
        }
        parts.append(date.formatted(date: .long, time: .omitted))

        if isSelected {
            parts.append("selected")
        }
        if actionCount > 0 {
            parts.append("\(actionCount) \(actionCount == 1 ? "action" : "actions") due")
        }
        if habitCount > 0 {
            parts.append("\(habitCount) \(habitCount == 1 ? "habit" : "habits") scheduled")
        }

        return parts.joined(separator: ", ")
    }

    // MARK: - Dot Logic

    private func actionCount(on date: Date) -> Int {
        actions.filter { action in
            guard let due = action.due else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }.count
    }

    private func habitCount(on date: Date) -> Int {
        habits.filter { $0.scheduled(for: date) }.count
    }

    // MARK: - Month Navigation

    private func daysInMonth() -> [Date] {
        let cal = weekCalendar
        guard
            let monthInterval = cal.dateInterval(of: .month, for: month),
            let monthFirstWeek = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            // Use the last moment of the month (not the exclusive end) so we get the week
            // containing the final day of the month, not the first week of the next month.
            let monthLastWeek = cal.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))
        else {
            return []
        }

        let firstDay = monthFirstWeek.start
        // monthLastWeek.end is the exclusive end of the last week; use strict less-than
        // so dates stop at the last day of that week (not one day into the next week).
        let lastDay = monthLastWeek.end

        var dates: [Date] = []
        var currentDate = firstDay

        while currentDate < lastDay {
            dates.append(currentDate)
            currentDate = cal.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }

    private func previousMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: month)!
    }

    private func nextMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: month)!
    }
}

extension Date {
    func formatted(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        switch format {
        case .day:
            formatter.dateFormat = "d"
        case .monthAndYear:
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: self)
    }
}

enum DateFormat {
    case day
    case monthAndYear
}
