# Habits

Habits are recurring behaviors with a schedule (day of week) and optional time-of-day. Users check in to track completion.

## What Are Habits?

- **Name** — Description (e.g., "Drink 8 cups of water")
- **Days** — `[Bool]` of length 7, one per weekday (order depends on `Calendar.firstWeekday`)
- **Time** — Minutes since midnight; `-1` = anytime
- **Check-ins** — History of completed days

## Display

### Habit List (`HabitListView`)

- Time (if set) in accent color
- Habit name
- **HabitWeekList** — Current week’s circles (S M T W T F S) with completion state
- Swipe: Mark Complete/Incomplete, Delete, Edit, Details

### HabitWeekList

- One circle per weekday
- Filled = checked in; outlined = not checked in
- Dimmed when habit is not scheduled that day
- Week layout respects `Calendar.firstWeekday`

### AltWeekList (Alternate View)

- Horizontal scroll of past and future days
- Infinite loading in both directions
- `HabitCheckinSource` preloads and lazily loads more days

## Editing

### HabitEditFields

- Name
- Milestone picker (optional)
- Day selector (tap circles to toggle on/off)

### EditHabitView

- Opens as sheet from habit list
- Uses HabitEditFields
- Stores `habitName`, `habitDays`, `habitHour`, `habitMinute` for editing

## Adding Habits

- From Milestone: Add → pick Habit → fill fields → Add

## Check-ins

- **hasCheckedIn(date:)** — Returns whether there is a check-in for that date
- **toggleCheckin(date:)** — Add or remove a check-in for the date
- **removeCheckin(date:)** — Returns matching check-in for manual removal

## Routines (`TodayRoutinesView`)

Habits are grouped by time of day:

| Bucket              | Time Range    |
|---------------------|---------------|
| All Day Habits      | `time < 0`    |
| Pre-Dawn Habits     | 0–6:00        |
| Morning Habits      | 6:00–12:00    |
| Afternoon Habits   | 12:00–17:00   |
| Evening Habits     | 17:00–22:00   |
| Night Habits       | 22:00–24:00   |

Only habits with `doToday == true` appear (based on `days` and current weekday).

## Data Model

```swift
Habit
├── name: String
├── days: [Bool]     // 7 elements
├── time: Int        // minutes since midnight; -1 = anytime
├── milestone: Milestone?
├── core_value: CoreValue?
└── checkins: [CheckIn]

CheckIn
├── date: Date
└── habit: Habit?
```

## Computed Properties

- **doToday** — Whether habit is scheduled for today
- **shiftedDays** — Days array rotated to match `firstWeekday`
- **timeDisplay** — Formatted time string (e.g., "8:00 AM") or empty if `time < 0`
