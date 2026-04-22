//
//  RoutineViews.swift
//  rallyops
//
//  Created by Cameron Rivers on 4/10/24.
//

import SwiftUI
import SwiftData

struct TodayRoutinesView: View {
    @Environment(\.modelContext) private var context
    @Query var allHabits: [Habit]
    var date: Date = Date()

    let buckets: [(String, Int)] = [
        ("PRE-DAWN ROUTINE", 0 * 60),   // Midnight - Pre-Dawn
        ("MORNING ROUTINE", 6 * 60),    // 6am - Morning
        ("AFTERNOON ROUTINE", 12 * 60), // 12pm - Afternoon
        ("EVENING ROUTINE", 17 * 60),   // 5pm - Evening
        ("NIGHT ROUTINE", 22 * 60),     // 10pm - Night
        ("", 24 * 60)
    ]

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        let routines = todaysRoutines()
        if routines.isEmpty {
            Section {
                Text(isToday ? "No habits scheduled for today" : "No habits scheduled for \(date.formatted(.dateTime.weekday(.wide)))")
                    .font(AppTheme.Typography.callout)
                    .italic()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } header: {
                Text("Habits")
                    .sectionHeaderStyle()
            }
        } else {
            ForEach(routines) { routine in
                Section {
                    HabitListView(habits: routine.habits, emphasizeToday: true)
                } header: {
                    Text(routine.name)
                        .sectionHeaderStyle()
                }
            }
        }
    }

    func todaysRoutines() -> [Routine] {
        var routines = [Routine]()
        let habits = todaysHabits()

        let allDayHabits = habits.filter { $0.time < 0 }
        if !allDayHabits.isEmpty {
            routines.append(Routine(name: "ALL DAY HABITS", habits: allDayHabits))
        }

        for idx in 0..<buckets.count-1 {
            let (name, start) = buckets[idx]
            let (_, end) = buckets[idx + 1]
            let h = habits
                .filter { $0.time >= start && $0.time < end }
                .sorted { $0.time < $1.time }

            if !h.isEmpty {
                routines.append(Routine(name: name, habits: h))
            }
        }

        return routines
    }

    func todaysHabits() -> [Habit] {
        return allHabits.filter { $0.scheduled(for: date) }
    }
}

struct Routine: Identifiable {
    let id = UUID()
    var habits = [Habit]()
    var name = ""

    init(name: String, habits: [Habit]) {
        self.name = name
        self.habits = habits
    }
}

#Preview {
    TodayRoutinesView()
}
