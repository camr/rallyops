# Data Helpers

This document covers utility methods, extensions, and helper functions for working with the app's data models.

## Action Extensions

**File:** `Models/Action+Extensions.swift`

### Action.filter(actions:for:)

Filters a list of actions to show only those relevant for a specific date.

```swift
static func filter(actions: [Action], for date: Date) -> [Action]
```

**Logic:**
- **Done actions:** Shows if completed on the target date (matches `doneDate`)
- **Incomplete actions:** Shows if due date is on or before end-of-day for the target date
- Returns actions sorted by due date (earliest first)

**Usage:**

```swift
let todayActions = Action.filter(actions: allActions, for: Date.now)
```

**Note:** There are two implementations of this filter in the codebase:
1. `Action+Extensions.swift` — Full implementation with done/incomplete logic
2. `Principle.swift` — Simpler version that only checks due date matches

## Model Extensions (Principle.swift)

### Milestone Extensions

#### [Milestone].sortByDate()

Sorts milestones by deadline in ascending order.

```swift
extension [Milestone] {
    func sortByDate() -> [Milestone]
}
```

**Usage:**

```swift
let sortedMilestones = coreValue.milestones.sortByDate()
```

#### Milestone.withActionAndHabit

Fetch descriptor for finding a single milestone that has both actions and habits.

```swift
static var withActionAndHabit: FetchDescriptor<Milestone>
```

**Usage:**

```swift
let descriptor = Milestone.withActionAndHabit
let results = try modelContext.fetch(descriptor)
```

### Action Extensions

#### Action.allTodo

Fetch descriptor for all incomplete actions, sorted by due date.

```swift
static let allTodo = FetchDescriptor<Action>(
    predicate: #Predicate { !$0.done },
    sortBy: [.init(\.due)]
)
```

**Usage:**

```swift
@Query(Action.allTodo) var pendingActions: [Action]
```

### Habit Extensions

#### habit.scheduled(for:)

Returns true if the habit is scheduled for the given date's weekday.

```swift
func scheduled(for date: Date) -> Bool
```

**Usage:**

```swift
if habit.scheduled(for: selectedDate) {
    // Show habit in today view
}
```

#### Habit.allHabits

Fetch descriptor for all habits sorted by name.

```swift
static let allHabits = FetchDescriptor<Habit>(
    sortBy: [.init(\.name)]
)
```

#### Habit.firstByName

Fetch descriptor for the first habit alphabetically (fetch limit 1).

```swift
static var firstByName: FetchDescriptor<Habit>
```

#### Habit.todayPredicate()

Predicate for habits scheduled today (uses `doToday` transient property).

```swift
static func todayPredicate() -> Predicate<Habit>
```

## Date Helpers

**File:** `Models/PrincipleV1.swift`

### Calendar Extensions

#### calendar.weekBoundary(for:)

Returns the start and end dates of the week containing the given date.

```swift
func weekBoundary(for date: Date = Date()) -> WeekBoundary?

typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
```

**Usage:**

```swift
if let boundary = Calendar.current.weekBoundary(for: selectedDate) {
    print("Week starts: \(boundary.startOfWeek)")
    print("Week ends: \(boundary.endOfWeek)")
}
```

### Date Extensions

#### date.calendar

Convenience property for `Calendar.autoupdatingCurrent`.

```swift
var calendar: Calendar
```

#### date.weekday

Returns the weekday index (1-7) adjusted for the calendar's first weekday.

```swift
var weekday: Int
```

**Usage:**

```swift
let day = Date.now.weekday  // 1 = Sunday, 2 = Monday, etc. (locale-aware)
```

#### Date.weekSymbols

Returns array of very short weekday symbols, rotated to match the calendar's first weekday.

```swift
static var weekSymbols: [String]
```

**Example output:** `["S", "M", "T", "W", "T", "F", "S"]` (in US locale)

#### date.short

Returns the full weekday name for the date.

```swift
var short: String
```

**Example:** "Monday"

## Utility Functions

### dateFromString(_:)

Parses a date string in "dd-MM-yyyy" format.

```swift
func dateFromString(_ str: String) -> Date
```

**Returns:** Parsed date or `Date.now` if parsing fails.

**Usage:**

```swift
let date = dateFromString("15-03-2024")
```

### until(days:)

Returns a date offset by the specified number of days from now.

```swift
func until(days: Int) -> Date
```

**Usage:**

```swift
let deadline = until(days: 30)  // 30 days from now
let pastDate = until(days: -5)  // 5 days ago
```

## Model Methods

### CoreValue

```swift
func addMilestone(_ milestone: Milestone)
func addAction(_ action: Action)
func addHabit(_ habit: Habit)
```

### Milestone

```swift
func addAction(_ action: Action)
func addHabit(_ habit: Habit)
func toggle()  // Toggle complete status
```

### Action

```swift
func toggle()  // Mark done/undone, sets doneDate

@Transient var pastDue: Bool  // True if due date is in the past
```

### Habit

```swift
func hasCheckedIn(date: Date = Date.now) -> Bool
func toggleCheckin(date: Date = Date.now) -> Void

@Transient var doToday: Bool        // True if scheduled for today
@Transient var shiftedDays: [Bool]  // Days array rotated for calendar firstWeekday
@Transient var timeDisplay: String  // Formatted time (e.g., "8:00 AM")
```

## Sample Data (Previewer)

**File:** `Models/Principle.swift`

The `Previewer` struct provides sample data for SwiftUI previews and testing.

```swift
@MainActor
struct Previewer {
    let container: ModelContainer

    init() throws {
        // Creates in-memory container with sample data
    }

    static func addSampleData(context: ModelContext)
}
```

**Usage in SwiftUI Previews:**

```swift
#Preview {
    if let previewer = try? Previewer() {
        ContentView()
            .modelContainer(previewer.container)
    }
}
```

**Sample Core Values:**
- Healthy Relationships
- Career Growth
- Physical Health
- Spiritual Connection
- Financial Stability
- Productivity

Each includes realistic milestones, actions, and habits.

## Best Practices

1. **Date Comparisons:** Use `Calendar.current.isDate(_:inSameDayAs:)` for day-level equality
2. **Weekday Logic:** Use `date.weekday` instead of `Calendar.component(.weekday)` for locale-aware indexing
3. **Filtering:** Prefer fetch descriptors with predicates over manual filtering for large datasets
4. **Transient Properties:** Use `@Transient` for computed properties to avoid SwiftData storage
5. **Relationships:** Use cascade delete rules to maintain referential integrity
