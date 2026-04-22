# Architecture

## App Entry Point

The app is defined in `RallyOpsApp.swift`:

- **Schema:** `CoreValue`, `Milestone`, `Action`, `Habit` (SwiftData models)
- **Migration:** `MigrationPlan` for schema evolution
- **Landing:** `LandingPageView` as the root view
- **macOS:** `SettingsView` appears in the native Settings menu

## Data Models

All models use SwiftData's `@Model` macro and follow the **PrincipleV1Schema** (defined in `Principle.swift` / `PrincipleV1.swift`).

### Relationship Hierarchy

```
CoreValue
├── milestones: [Milestone]
├── actions: [Action]     (direct, not tied to a milestone)
└── habits: [Habit]       (direct, not tied to a milestone)

Milestone
├── core_value: CoreValue?
├── actions: [Action]
└── habits: [Habit]

Action
├── milestone: Milestone?
└── core_value: CoreValue?

Habit
├── milestone: Milestone?
├── core_value: CoreValue?
└── checkins: [CheckIn]

CheckIn
└── habit: Habit?
```

### Model Details

| Model | Key Properties |
|-------|----------------|
| **CoreValue** | `name`, `details`, `createdAt` |
| **Milestone** | `name`, `deadline`, `complete` |
| **Action** | `name`, `due`, `done`, `doneDate` |
| **Habit** | `name`, `days` (7 bools), `time` (minutes since midnight, -1 = anytime) |
| **CheckIn** | `date`, `habit` |

### Delete Rules

Relationships use `deleteRule: .cascade` so deleting a CoreValue removes its milestones, actions, and habits; deleting a Milestone removes its actions and habits.

## File Structure

```
rallyops/
├── RallyOpsApp.swift          # App entry, schema, model container
├── ContentModel.swift      # Observable state (minimal, reserved for future use)
├── Models/
│   ├── Principle.swift     # CoreValue, Milestone, Action, Habit, CheckIn
│   ├── PrincipleV1.swift   # Same models, versioned schema
│   ├── PrincipleMigrationPlan.swift
│   └── Action+Extensions.swift
├── Views/
│   ├── HomeView.swift      # Landing, Today tab, Calendar sheet
│   ├── CoreValueViews.swift
│   ├── MilestoneListView.swift
│   ├── Milestones/
│   │   ├── CreateMilestoneView.swift
│   │   └── CreateMilestoneValidator.swift
│   ├── ActionItemViews.swift
│   ├── HabitViews.swift
│   ├── RoutineViews.swift
│   ├── GridCalendarView.swift
│   ├── SettingsView.swift
│   ├── CreateGoalView.swift
│   └── FirstGoalWalkthrough.swift
└── Assets.xcassets/
```

## Sample Data

`Previewer` in `Principle.swift` adds sample data for Xcode previews and debug use:

- Healthy Relationships
- Career Growth
- Physical Health
- Spiritual Connection
- Financial Stability
- Productivity

Use **Add Demo Data** in Settings → Debug to insert sample data at runtime.
