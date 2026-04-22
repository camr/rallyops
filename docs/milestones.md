# Milestones

Milestones are time-bound rallyops tied to a Core Value. They group Actions and Habits that move the user toward a specific outcome by a deadline.

## What Are Milestones?

- **Name** — e.g., "Reach a healthy BMI by the end of summer"
- **Deadline** — Target completion date
- **Complete** — Whether the milestone is done

## Views

### Milestones Tab

Accessed via the **Milestones** tab (trophy icon).

- Segmented browse mode:
  - **By Value** — Grouped by Core Value
  - **By Date** — Flat list sorted by deadline
- Each section shows milestones sorted by deadline
- Empty sections show "No Milestones" with a prompt to create one
- Toolbar: **Create Milestone** (opens `CreateMilestoneView`)
- Tap a milestone to open its detail view

### Milestone Detail View (`MilestoneView`)

- Header: milestone name and "Next Check-in" (deadline)
- **Actions** section — Tasks for this milestone
- **Habits** section — Recurring habits for this milestone
- Toolbar: **Add** — Opens sheet to add an Action or Habit
- Empty state when no actions or habits

### Create Milestone (`CreateMilestoneView`)

- **Name** — Text field
- **Core Value** — Picker (required)
- **Deadline** — Date picker (must be today or future)
- **Create** / **Cancel** in toolbar
- Validation errors shown in footer
- Submitting shows progress overlay; dismisses on success

## Validation (`CreateMilestoneValidator`)

A milestone is valid only if:

1. **Name** — Non-empty
2. **Core Value** — Assigned
3. **Deadline** — `>= Date.now` (not in the past)

Error messages:

- "The milestone must be associated with a Core Value"
- "The milestone must have a valid name"
- "The milestone must have a deadline in the future"

## Adding Actions and Habits to a Milestone

From `MilestoneView` → **Add**:

- **CreateActionOrHabitSheet** — Segmented picker for Action or Habit
- Uses `ActionItemEditFields` or `HabitEditFields`
- Cancel confirms when there are unsaved changes
- **Add** saves and dismisses

## Data Model

```swift
Milestone
├── name: String
├── deadline: Date
├── complete: Bool
├── core_value: CoreValue?
├── actions: [Action]
└── habits: [Habit]
```

## Milestones by Date View

`MilestonesByDateView` presents milestones in a flat list sorted by deadline with Core Value shown. It is available in the Milestones tab via the **By Date** segmented option.
