# Calendar

The app supports date selection for the Today view. There are two calendar implementations:

## Inline Calendar (HomeView.swift)

Used in the Today view as the sheet when tapping the date or the Calendar toolbar button.

### Features

- **DatePicker** with `.graphical` style
- **Selection** — Binding to the displayed date
- **Done** — Dismisses the sheet
- **Today** — Sets date to now and dismisses

### Usage

```swift
CalendarView(showingDate: $showingDate)
```

## Custom Calendar (GridCalendarView.swift)

A standalone grid-based calendar view (in `rallyops/Views/GridCalendarView.swift`).

### Features

- Month/year header with previous/next month buttons
- 7-column grid of days
- Highlights the selected date (blue circle)
- Tap a day to set `showingDate`
- `daysInMonth()` builds a grid spanning first to last week of the month
- Respects `Calendar.current` for month/week boundaries

### Date Extensions

- `Date.formatted(.day)` → "d" format
- `Date.formatted(.monthAndYear)` → "MMMM yyyy" format

## Note

The `CalendarView` in `HomeView.swift` (DatePicker-based) is the one used in the Today tab. The `GridCalendarView` in `GridCalendarView.swift` can be swapped in for a different date selection UX. Both accept `Binding<Date>`.
