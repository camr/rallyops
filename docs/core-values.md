# Core Values

Core Values are high-level life principles that guide rallyops and behavior. They sit at the top of the hierarchy and organize milestones, actions, and habits.

## What Are Core Values?

- **Name** — e.g., "Physical Health", "Career Growth"
- **Details** — Optional description
- **Created At** — Timestamp (set on creation)

## Views

### Core Values Tab

Accessed via the **Core Values** tab (triangle icon) in the main tab bar.

- Lists all core values sorted by name
- Shows milestone count per value
- Red caption when there are no milestones
- Tap a value to open its detail view

### Core Value Detail View

- Lists milestones belonging to that core value
- Tap a milestone to open `MilestoneView`

## Data Model

```swift
CoreValue
├── name: String
├── details: String
├── createdAt: Date
├── milestones: [Milestone]
├── actions: [Action]
└── habits: [Habit]
```

Actions and habits can be attached directly to a Core Value or to a Milestone under that value.

## Creating Core Values

Core Values are created indirectly:

1. **First Goal Walkthrough** — As part of onboarding (Step 1)
2. **Create Milestone** — Must pick a Core Value when creating a milestone; if none exist, they may need to be seeded via demo data
3. **Debug Settings** — "Add Demo Data" creates sample core values

There is no standalone "Add Core Value" screen in the current UI. Use demo data or the walkthrough to establish the first values.

## Sample Core Values (Demo Data)

When adding demo data:

- Healthy Relationships
- Career Growth
- Physical Health
- Spiritual Connection
- Financial Stability
- Productivity
