# Today View

The Today view is the primary daily view. It shows actions and habits for the selected date and is the first tab in the main tab bar.

## Layout

- **Header:** Selected date (abbreviated), "Today" shortcut when not viewing today
- **Toolbar:** Calendar button (leading), Settings button (trailing)
- **Content:**
  - **Actions** — `TodayActionItemsView` — Actions filtered for the selected date
  - **Routines** — `TodayRoutinesView` — Habits grouped by time of day

## Date Selection

- Tap the date header to open the Calendar sheet
- Use **Today** when viewing another date to jump back
- The Calendar sheet lets you pick a date (see [Calendar](calendar.md))

## TodayActionItemsView

- Queries all actions, sorted by due date
- Filters with `Action.filter(actions:for: date)`:
  - Incomplete: due on or before end of selected day
  - Complete: done on the selected day
- Renders using `ActionItemsListView`

## TodayRoutinesView

- Queries all habits
- Filters to `doToday` (scheduled for the selected weekday)
- Groups by time buckets (All Day, Pre-Dawn, Morning, Afternoon, Evening, Night)
- Renders each section with `HabitListView`

## Navigation

- **Settings** — Opens Settings sheet
- **Calendar** — Opens date picker / calendar sheet
