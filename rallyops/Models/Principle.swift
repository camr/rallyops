//
//  CoreValue.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/19/24.
//

import Foundation
import SwiftData

// MARK: Type Aliases

typealias RallyOpsSchema = PrincipleV1Schema
typealias CoreValue = RallyOpsSchema.CoreValue
typealias Milestone = RallyOpsSchema.Milestone
typealias Action = RallyOpsSchema.Action
typealias Habit = RallyOpsSchema.Habit
typealias CheckIn = RallyOpsSchema.CheckIn

// MARK: Extensions

extension [Milestone] {
    func sortByDate() -> [Milestone] {
        return self.sorted { $0.deadline < $1.deadline }
    }
}

// MARK: Sample Date

@MainActor
struct Previewer {
    let container: ModelContainer

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: CoreValue.self, configurations: config)

        Previewer.addSampleData(context: container.mainContext)
    }

    static func addSampleData(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<CoreValue>())) ?? []
        let existingNames = Set(existing.map { $0.name })

        if !existingNames.contains("Healthy Relationships") { healthyRelationships(context) }
        if !existingNames.contains("Career Growth") { careerGrowth(context) }
        if !existingNames.contains("Physical Health") { physicalHealth(context) }
        if !existingNames.contains("Spiritual Connection") { spiritualConnection(context) }
        if !existingNames.contains("Financial Stability") { financialStability(context) }
        if !existingNames.contains("Productivity") { productivity(context) }
    }

    static func healthyRelationships(_ context: ModelContext) {
        let v = CoreValue("Healthy Relationships")
        v.details = "Foster relationships that help me improve and be my true self."
        context.insert(v)

        v.addHabit(Habit("Call mom once a week",
                         days: [true, false, false, false, false, false, false]
                        ))

        let m1 = Milestone("Plan a birthday party for my sister", deadline: until(days: 30))
        v.addMilestone(m1)

        m1.addAction(Action("Coordinate date for party", due: until(days: -5)))
        m1.addAction(Action("Come up with birthday theme ideas", due: until(days: 0)))

        let m2 = Milestone("Attend 10 book club meetings this year", deadline: until(days: 180))
        v.addMilestone(m2)

        m2.addAction(Action("Buy this month's book club book", due: until(days: -4)))
        m2.addHabit(Habit("Read this month's book for 10 minutes",
                          days: [true, true, true, true, true, true, true],
                          time: 20 * 60 // 8:00pm
                         ))
    }

    static func careerGrowth(_ context: ModelContext) {
        let v = CoreValue("Career Growth")
        v.details = "Enjoying my work, finding a healthy work/life balance and continuously improving."
        context.insert(v)

        let m1 = Milestone("Find a career mentor", deadline: until(days: 60))

        m1.addAction(Action("Research mentor/mentee relationships", due: until(days: 5)))
        m1.addHabit(Habit("Write one question for a potential mentor about this week",
                          days: [false, false, false, false, false, true, false],
                          time: 17 * 60 + 30
                         ))

        v.addMilestone(m1)
    }

    static func physicalHealth(_ context: ModelContext) {
        let v = CoreValue("Physical Health")
        v.details = "Live a longer, happier life and be able to help others."
        context.insert(v)

        let m1 = Milestone("Reach a health BMI by the end of the summer", deadline: until(days: 90))
        v.addMilestone(m1)

        m1.addAction(Action("Get a full-body wellness check up", due: until(days: 7)))
        m1.addHabit(Habit("Make a healthy meal plan for the week",
                          days: [true, false, false, false, false, false, false],
                          time: 10 * 60
                         ))
        m1.addHabit(Habit("Avoid foods that are mostly sugar",
                          days: [true, true, true, true, true, true, true],
                          time: -1
                         ))
        let water = Habit("Drink 8 cups of water",
                          days: [true, true, true, true, true, true, true],
                          time: -1
                         )
        m1.addHabit(water)

        water.toggleCheckin(date: until(days: -2))
        water.toggleCheckin(date: until(days: -1))

        let m2 = Milestone("Be able to bench press 200 lbs", deadline: until(days: 120))
        v.addMilestone(m2)

        m2.addAction(Action("Join a gym", due: until(days: 10)))
        m2.addHabit(Habit("Go to the gym for at least 30 minutes",
                          days: [false, true, false, true, false, true, false],
                          time: 8 * 60
                         ))
    }

    static func spiritualConnection(_ context: ModelContext) {
        let v = CoreValue("Spiritual Connection")
        v.details = "Feel a sense of belonging outside of my immediate community."
        context.insert(v)

        let m1 = Milestone("Attend church at least once a month", deadline: until(days: 180))
        v.addMilestone(m1)

        m1.addHabit(Habit("Layout clothes for church",
                          days: [false, false, false, false, false, false, true],
                          time: 20 * 60
                         ))
    }

    static func financialStability(_ context: ModelContext) {
        let v = CoreValue("Financial Stability")
        v.details = "Live comfortably and be able to contribute to my family's expenses."
        context.insert(v)

        let m1 = Milestone("Save $2000", deadline: until(days: 60))

        m1.addAction(Action("Open savings account", due: until(days: 21)))
        m1.addHabit(
            Habit("Track weekly spending",
                  days: [true, false, true, false, true, false, false],
                  time: 21 * 60
            )
        )

        v.addMilestone(m1)
    }

    static func productivity(_ context: ModelContext) {
        let v = CoreValue("Productivity")
        v.details = "Be productive and achieve my rallyops every day."
        context.insert(v)
    }
}

extension Milestone {
    static var withActionAndHabit: FetchDescriptor<Milestone> {
        var descriptor = FetchDescriptor<Milestone>(
            predicate: #Predicate { !$0.actions.isEmpty && !$0.habits.isEmpty },
            sortBy: [
                .init(\.deadline)
            ]
        )
        descriptor.fetchLimit = 1

        return descriptor
    }
}

extension Action {
    static let allTodo = FetchDescriptor<Action>(
        predicate: #Predicate { !$0.done },
        sortBy: [
            .init(\.due)
        ]
    )

    static func filter(actions: [Action], for date: Date) -> [Action] {
        let cal = Calendar.current
        return actions
            .filter { action in
                guard let due = action.due else { return false }
                return cal.isDate(due, inSameDayAs: date)
            }
            .sorted { ($0.due ?? Date.distantPast) < ($1.due ?? Date.distantPast) }
    }
}

extension Habit {
    /// Returns true if this habit is scheduled for the given date's weekday.
    func scheduled(for date: Date) -> Bool {
        let weekday = date.weekday
        return self.days[weekday % 7]
    }

    static let allHabits = FetchDescriptor<Habit>(
        sortBy: [
            .init(\.name)
        ]
    )

    static var firstByName: FetchDescriptor<Habit> {
        var descriptor = FetchDescriptor<Habit>(
            sortBy: [ .init(\.name)]
        )
        descriptor.fetchLimit = 1

        return descriptor
    }

    static func todayPredicate() -> Predicate<Habit> {
        #Predicate<Habit> { $0.doToday }
    }
}

func dateFromString(_ str: String) -> Date {
    let dtFormatter = DateFormatter()
    dtFormatter.dateFormat = "dd-MM-yyyy"

    if let dt = dtFormatter.date(from: str) {
        return dt
    }

    return Date.now
}

func until(days: Int) -> Date {
    return Date.now.advanced(by: TimeInterval(Double(days) * 24.0 * 60.0 * 60.0))
}
