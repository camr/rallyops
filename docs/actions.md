# Actions

Actions are one-time tasks with optional due dates. They can belong to a Milestone or directly to a Core Value.

## What Are Actions?

- **Name** — Task description
- **Due** — Optional due date
- **Done** — Completion flag
- **Done Date** — When it was marked complete (if done)

## Display

### Action List (`ActionItemsListView`)

- Checkbox (tap to toggle complete)
- Name (strikethrough when done)
- Due date (numeric)
- Due date styled red when past due

### Swipe Actions

- **Leading (full swipe):** Mark Complete / Mark Incomplete
- **Trailing:** Delete, Edit

## Editing

### Edit Action (`EditActionView`)

- Opens as a sheet when swiping **Edit**
- **ActionItemEditFields** — Name, Milestone picker (optional), Due date
- Save / Cancel with unsaved-changes confirmation

### Adding Actions

1. **From Milestone** — Add → pick Action Item → fill fields → Add
2. **Standalone** — Not exposed in current UI; actions are created under milestones

## Today View Filtering

Actions shown in the Today view are filtered by the selected date:

- **Incomplete:** Due on or before end of selected day
- **Complete:** Marked done on the selected day

Order: sorted by due date.

## Data Model

```swift
Action
├── name: String
├── due: Date?
├── done: Bool
├── doneDate: Date?
├── milestone: Milestone?
└── core_value: CoreValue?
```

## Computed Properties

- **pastDue** — `true` when `due` is before today (by day granularity)

## Toggle

`action.toggle()` sets `done` / `doneDate`:

- If not done → mark done, set `doneDate = Date.now`
- If done → mark incomplete, clear `doneDate`
