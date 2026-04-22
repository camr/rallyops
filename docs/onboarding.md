# Onboarding

The app shows the First Goal Walkthrough on first launch when there are no Core Values. Once data exists (or is added via the walkthrough), the app shows `LandingPageView`.

## App Root Logic

`AppRootView` (in `RallyOpsApp`) checks Core Value count:

- **Empty** → `FirstGoalWalkthroughContainer` (full walkthrough)
- **Has data** → `LandingPageView` (main tabs)

## First Goal Walkthrough

A multi-step flow in `FirstGoalWalkthrough.swift`:

### Step 0 — Welcome (`FirstGoalWalkthroughStart`)

- Welcome text introducing the app
- "Ready to start shaping your future? Let's begin!"
- **Start My Journey** → Step 1

### Step 1 — Core Value (`FirstGoalWalkthroughStep1`)

- Explains "What is a core value?"
- TextField placeholder: "Friendship"
- **Create Your First Goal** → Step 2

### Step 2 — Milestone (`FirstGoalWalkthroughStep2`)

- "Establish a milestone you would like to reach"
- TextField placeholder: "Reconnect with 3 lost friends by October"
- **Create a Follow Up Task** → Step 3

### Step 3 — One-Time Task (`FirstGoalWalkthroughStep3`)

- "Create a task to help you achieve your goal"
- TextField placeholder: "Text someone you haven't talked to in a while"
- **Start a beneficial habit** → Step 4

### Step 4 — Recurring Habit (`FirstGoalWalkthroughStep4`)

- "Start a habit that will help you achieve your goal"
- TextField placeholder: "Reach out to people in your contact list"
- **Get Started** → Persists all data to SwiftData and navigates to main app

## Create Goal View

`CreateGoalView` in `CreateGoalView.swift` is a standalone form:

- **New Goal** header
- **Goal Name** text field
- **Enter Habit** text field + Add button
- List of added habits (display only; no persistence)

This view is not wired into navigation or SwiftData. It appears to be a prototype or work-in-progress.

## Persistence

`WalkthroughData` holds valueName, milestoneName, taskName, habitName across steps. On **Get Started**:

1. **Core Value** (required) — Created from Step 1 name
2. **Milestone** (optional) — Deadline 30 days from now; linked to Core Value
3. **Action** (optional) — Due 7 days from now; linked to Milestone
4. **Habit** (optional) — All days enabled, anytime; linked to Milestone

After save, the `@Query` in `AppRootView` updates and the main app is shown.
