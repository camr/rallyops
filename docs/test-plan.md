# Test Plan

This document tracks test coverage, test scenarios, and testing history for the RallyOps app.

**Last Updated**: 2026-02-21
**Maintained By**: Testing Agents

## Coverage Status

| Feature Area | Last Tested | Coverage | Open Issues | Notes |
|--------------|-------------|----------|-------------|-------|
| Core Values - Create | Never | ⚠️ Not Tested | - | Priority: High |
| Core Values - Edit | Never | ⚠️ Not Tested | - | |
| Core Values - Delete | Never | ⚠️ Not Tested | - | |
| Core Values - List View | 2026-02-15 | ✅ Full | Duplicate bug | |
| Core Values - Detail View | 2026-02-15 | ✅ Full | Works well | |
| Milestones - Create | Never | ⚠️ Not Tested | - | Priority: High |
| Milestones - Edit | Never | ⚠️ Not Tested | - | |
| Milestones - Delete | Never | ⚠️ Not Tested | - | |
| Milestones - List View | Never | ⚠️ Not Tested | - | |
| Milestones - Detail View | 2026-02-15 | ⚠️ Partial | Display OK | |
| Milestones - Filter (By Value) | Never | ⚠️ Not Tested | - | |
| Milestones - Filter (By Date) | Never | ⚠️ Not Tested | - | |
| Actions - Create | Never | ⚠️ Not Tested | - | |
| Actions - Complete | 2026-02-15 | ❌ Failed | Checkbox broken | |
| Actions - Delete | Never | ⚠️ Not Tested | - | |
| Settings - General | 2026-02-15 | ⚠️ Partial | Accessible | |
| Settings - Debug Tools | 2026-02-15 | ✅ Full | Works well | |
| Habits - Create | Never | ⚠️ Not Tested | - | Priority: High |
| Habits - Edit | Never | ⚠️ Not Tested | - | |
| Habits - Delete | Never | ⚠️ Not Tested | - | |
| Habits - Daily Check-in | Never | ⚠️ Not Tested | - | |
| Habits - Day Schedule | Never | ⚠️ Not Tested | - | |
| Today View - Navigation | 2026-02-21 | ❌ Failed | Tab nav still broken [td-90278d] | Priority: High |
| Today View - Date Selection | 2026-02-21 | ❌ Failed | Calendar selection still broken [td-9adb66] | |
| Today View - Actions List | 2026-02-21 | ❌ Failed | No empty state shown [td-df51df] | |
| Today View - Habits List | 2026-02-21 | ❌ Failed | Check-in circles navigate instead of checking in [td-d5b03b] | |
| Today View - Milestones Section | 2026-02-21 | ❌ Failed | Section header present but empty [td-39442b] | |
| Calendar - Date Picker | 2026-02-21 | ❌ Failed | Date selection broken, no day headers [td-9adb66, td-67f810] | |
| Calendar - Navigation | 2026-02-21 | ⚠️ Partial | Opens/closes OK, month display OK | |
| Habits - Daily Check-in | 2026-02-21 | ❌ Failed | Not interactive from Today view | Priority: CRITICAL |
| Settings - General | Never | ⚠️ Not Tested | - | |
| Settings - Debug Tools | Never | ⚠️ Not Tested | - | |
| Onboarding - First Launch | Never | ⚠️ Not Tested | - | Priority: High |
| Onboarding - Create First Goal | Never | ⚠️ Not Tested | - | |

**Coverage Legend:**
- ✅ **Full**: All critical scenarios tested, no known issues
- ⚠️ **Partial**: Some scenarios tested, gaps remain
- ❌ **Failed**: Testing blocked or feature broken
- **Never**: Not yet tested

## Test Scenarios

### Core Values

#### Create Core Value
**Reference**: `docs/core-values.md`

- [ ] Create value with valid name and description
- [ ] Verify value appears in Core Values tab
- [ ] Verify value appears in milestone creation dropdown
- [ ] Empty name validation error
- [ ] Very long name handling (>100 characters)
- [ ] Special characters in name (emoji, symbols)
- [ ] Cancel creation flow
- [ ] Create multiple values back-to-back

#### Edit Core Value
- [ ] Edit name of existing value
- [ ] Edit description of existing value
- [ ] Changes reflect in milestone associations
- [ ] Cancel edit flow

#### Delete Core Value
- [ ] Delete value with no associated milestones
- [ ] Attempt delete value with associated milestones (should block or cascade)
- [ ] Undo delete (if supported)

### Milestones

#### Create Milestone
**Reference**: `docs/milestones.md`

- [ ] Create milestone with valid name, core value, and future deadline
- [ ] Milestone appears in Milestones tab
- [ ] Milestone appears in correct core value section
- [ ] Empty name validation error
- [ ] Missing core value validation error
- [ ] Past deadline validation error (per CreateMilestoneValidatorTests)
- [ ] Current date/time as deadline validation error
- [ ] Very long name handling
- [ ] Special characters in name
- [ ] Cancel creation flow

#### Edit Milestone
- [ ] Edit milestone name
- [ ] Edit milestone deadline
- [ ] Change associated core value
- [ ] Edit milestone description
- [ ] Changes reflect in all views

#### Filter Milestones
- [ ] Filter "By Value" shows correct groupings
- [ ] Filter "By Date" shows chronological order
- [ ] Switch between filter modes
- [ ] Empty states when no milestones for filter

### Actions

#### Create Action
**Reference**: `docs/actions.md`

- [ ] Create action with name and due date
- [ ] Action appears in Today view on due date
- [ ] Action appears in correct milestone (if associated)
- [ ] Empty name validation
- [ ] Past due date handling
- [ ] No due date (optional date handling)

#### Complete Action
- [ ] Mark action as complete
- [ ] Completed action visual state
- [ ] Completed action disappears from active list (if that's the behavior)
- [ ] Undo completion (if supported)

### Habits

#### Create Habit
**Reference**: `docs/habits.md`

- [ ] Create all-day habit with valid name
- [ ] Create time-based habit with specific time
- [ ] Set day-of-week schedule (select multiple days)
- [ ] Habit appears in Today view on scheduled days
- [ ] Habit does NOT appear on non-scheduled days
- [ ] Empty name validation
- [ ] No days selected validation
- [ ] Time picker for time-based habits

#### Daily Check-in
- [ ] Tap day circle to mark complete (should fill circle)
- [ ] Tap filled circle to undo completion
- [ ] Check-in persists across app restarts
- [ ] Check-in for past dates
- [ ] Check-in for future dates (should be prevented?)
- [ ] Visual feedback on tap (haptic? animation?)

#### Day Schedule
- [ ] Habit shows correct days active (M/T/W/T/F/S/S indicators)
- [ ] Current day highlighted appropriately
- [ ] Completed days show filled state
- [ ] Incomplete days show empty state

### Today View

#### Navigation
**Reference**: `docs/today-view.md`

- [ ] Today tab loads on app launch
- [ ] Calendar icon opens date picker
- [ ] Plus icon opens create action flow
- [ ] Settings icon opens settings
- [ ] Tab bar switches between Today/Milestones/Core Values

#### Date Selection
- [ ] Calendar picker shows current month
- [ ] Select past date → view updates to that date
- [ ] Select future date → view updates to that date
- [ ] Date header shows selected date
- [ ] Return to today (is there a shortcut?)

#### Content Display
- [ ] ACTIONS section shows due actions for selected date
- [ ] ALL DAY HABITS section shows habits scheduled for that day-of-week
- [ ] EVENING HABITS section shows time-based habits
- [ ] Empty states when no actions/habits
- [ ] Correct day-of-week highlighting in habit circles

### Calendar

#### Date Picker
**Reference**: `docs/calendar.md`

- [ ] Calendar opens from Today view
- [ ] Shows current month by default
- [ ] Navigate to past months
- [ ] Navigate to future months
- [ ] Select date updates Today view
- [ ] Close calendar returns to Today view

### Settings

#### General Settings
**Reference**: `docs/settings.md`

- [ ] Settings accessible from gear icon
- [ ] Each setting can be toggled/modified
- [ ] Changes persist across app restarts
- [ ] Cancel/Save behavior (if applicable)

#### Debug Tools
- [ ] Debug tools visible in development builds
- [ ] Debug actions function correctly
- [ ] No debug tools in release builds

### Onboarding

#### First Launch
**Reference**: `docs/onboarding.md`

- [ ] Onboarding appears on first launch only
- [ ] Walkthrough explains core concepts
- [ ] Can proceed through all onboarding screens
- [ ] Skip option (if available)
- [ ] Create first goal flow

#### Create First Goal Flow
- [ ] Prompts to create first core value
- [ ] Prompts to create first milestone
- [ ] Explains habit tracking concept
- [ ] Lands in appropriate view after completion

## End-to-End Test Scenarios

### Complete User Journey: New User to First Habit Check-in
1. Launch app (fresh install)
2. Complete onboarding
3. Create first core value ("Health & Fitness")
4. Create first milestone ("Run a 5K race" by [future date])
5. Create daily habit ("Run 2 miles" - M/W/F)
6. Navigate to Today view
7. Mark habit complete for today
8. Verify completion persists

### Complete User Journey: Weekly Planning
1. Navigate to Milestones tab
2. Review upcoming milestone deadlines
3. Create action item for closest deadline
4. Navigate to Today view
5. Verify action appears on due date
6. Complete action
7. Check habit progress for the week

## Accessibility Test Scenarios

- [ ] VoiceOver: All interactive elements have labels
- [ ] VoiceOver: Can navigate entire app with screen reader
- [ ] VoiceOver: Form inputs announce purpose and current value
- [ ] Dynamic Type: Text scales appropriately
- [ ] Dynamic Type: Layout adapts without clipping
- [ ] Color Contrast: Meets WCAG AA standards
- [ ] Tap Targets: All buttons/controls ≥44x44pt
- [ ] Haptic Feedback: Appropriate haptic cues on interactions

## Performance Test Scenarios

- [ ] App launch time <2 seconds
- [ ] Today view loads instantly with 100+ habits
- [ ] Milestone list scrolls smoothly with 100+ milestones
- [ ] No lag when marking habits complete
- [ ] No memory leaks during extended use
- [ ] Data persists correctly across app restarts

## Edge Cases & Stress Tests

- [ ] Create 1000 milestones (performance test)
- [ ] Milestone with deadline in distant future (year 2050)
- [ ] Milestone with deadline tomorrow 11:59 PM
- [ ] Habit scheduled for all 7 days
- [ ] Habit scheduled for 0 days (validation error?)
- [ ] Very long text in all input fields (>500 characters)
- [ ] Emoji and special characters in all text fields
- [ ] Rapid tapping on buttons (double-submit prevention)
- [ ] Navigate between dates rapidly
- [ ] Delete core value with 100+ milestones

## Known Issues

All bugs are tracked in the `td` task system. Use `td list --labels bug` to see current bugs.

To view bugs by priority:
- `td list --labels bug --priority critical` - P0 critical bugs blocking core functionality
- `td list --labels bug --priority high` - P1 high priority bugs
- `td list --labels bug --priority medium` - P2 medium priority bugs
- `td list --labels bug,ui` - UI-related bugs
- `td list --labels bug,habits` - Habit feature bugs

## Test History

### Session Log
Test sessions will be logged here with brief summaries and links to detailed notes.

**Format:**
```markdown
#### YYYY-MM-DD: [Feature Area Tested]
- **Tester**: [Agent ID]
- **Coverage**: [Specific scenarios tested]
- **Findings**: X bugs, Y improvements, Z insights
- **Tasks Created**: [TD-XXX, TD-YYY, TD-ZZZ]
- **Notes**: [Link to detailed session notes if applicable]
```

#### 2026-02-21: Home Screen / Today View Deep Dive
- **Tester**: Claude Sonnet 4.6 (Testing Agent)
- **Device**: iPhone 16e Simulator, iOS 18 (booted)
- **Branch**: fix/ipad-multitasking-orientations
- **Coverage**: Today view full scroll, habit cards, ACTIONS section, calendar picker, New Action form, tab bar navigation, section headers, accessibility tree
- **Findings**: 12 issues found (3 bugs re-confirmed still present, 9 new findings)
- **Tasks Created**: [td-df51df, td-432aee, td-00dc9d, td-a88d9e, td-67f810, td-9adb66, td-f7307e, td-90278d, td-6cb692, td-39442b, td-d5b03b, td-00d473, td-00833f]
- **Status**: ❌ CRITICAL ISSUES STILL PRESENT - core interactions non-functional

**What Worked:**
- ✅ App launches directly to Today view with correct date header
- ✅ Habit cards render correctly with streak counts and day circle indicators
- ✅ Tapping a habit card body navigates to habit detail view
- ✅ Habit detail view shows stats (Streak, This Week) and milestone association
- ✅ Calendar picker opens and closes correctly, month display is correct
- ✅ New Action sheet opens from '+' button
- ✅ Settings icon in nav bar is present (not tested in depth this session)
- ✅ Today tab itself is selectable and active

**What Failed / Issues Found:**
- ❌ ACTIONS section has no empty state — blank space with no guidance [td-df51df] **P2**
- ❌ Section headers use inconsistent casing (ACTIONS vs Morning Habits) [td-432aee] **P3**
- ❌ New Action 'Add' button appears enabled with empty name, silent on tap [td-00dc9d] **P2**
- ❌ New Action due date picker row is not tappable [td-a88d9e] **P2**
- ❌ Calendar has no day-of-week column headers [td-67f810] **P3**
- ❌ Calendar date selection still broken (re-confirmed from td-562023) [td-9adb66] **P1**
- ❌ Calendar sheet has large empty whitespace below grid [td-f7307e] **P4**
- ❌ Tab bar: Search and Milestones tabs still unresponsive (re-confirmed) [td-90278d] **P1**
- ❌ Tab bar button accessibility names use SF Symbol IDs, not readable text [td-6cb692] **P2**
- ❌ MILESTONES section on Today view has no content or empty state [td-39442b] **P2**
- ❌ Habit day circles navigate to detail instead of checking in [td-d5b03b] **P2**
- ⚠️ Test data habit name 'Asdfasd' visible in simulator [td-00d473] **P3**
- ⚠️ Calendar overflow dates from adjacent months not visually differentiated [td-00833f] **P3**

**Key Insight:**
Multiple previously-closed bugs appear to still be present (calendar date selection, tab bar navigation). Either the fixes were not fully effective or they regressed. The core habit check-in flow remains entirely non-functional — users cannot mark a habit complete from any view in the app.

#### 2026-02-15: Today View & Tab Navigation
- **Tester**: Claude Sonnet 4.5 (Testing Agent)
- **Device**: iPhone 16e Simulator, iOS 18.6
- **Coverage**: Today view navigation, habit check-in UI, calendar date picker, tab bar navigation
- **Findings**: 4 bugs found, 2 features working
- **Tasks Created**: [td-b6d193, td-4c19d3, td-d180cc, td-562023]
- **Status**: ⚠️ CRITICAL ISSUES FOUND - P0 bug blocking core functionality

**What Worked:**
- ✅ Calendar picker opens and closes correctly
- ✅ Today view layout renders properly (date header, sections, habit cards)
- ✅ Current day highlighting works correctly
- ✅ Historical check-in data displays (read-only)

**What Failed:**
- ❌ Habit check-in completely non-functional - day circles are static text, not buttons [td-4c19d3] **P0 CRITICAL**
- ❌ Tab navigation unresponsive from Milestones → Today [td-b6d193]
- ❌ Habit cards not tappable [td-d180cc]
- ❌ Calendar date selection not responding [td-562023]

**Key Insight:**
Today view functions as read-only dashboard. Core interaction pattern (tapping day circles to check in habits) is not implemented - UI elements are StaticText, not Buttons.

#### 2026-02-15 (Session 2): Core Values, Milestones, Settings Navigation
- **Tester**: Claude Sonnet 4.5 (Testing Agent)
- **Device**: iPhone 16e Simulator, iOS 18.6
- **Coverage**: Core Values list/detail, Milestone detail, Settings, Debug tools, tab navigation (Today↔Core Values)
- **Findings**: 2 bugs found, 8 features working correctly
- **Tasks Created**: [td-d1a25b, td-d5cf5c]
- **Status**: ✅ Navigation mostly works, but core interactions still broken

**What Worked:**
- ✅ Tab navigation: Today → Core Values works
- ✅ Tab navigation: Core Values → Today works
- ✅ Core Values list displays with milestone counts
- ✅ Core Value detail view shows name, description, associated milestones
- ✅ Milestone detail view shows actions and habits
- ✅ Settings accessible and well-organized
- ✅ Debug view provides useful data stats and testing tools
- ✅ Navigation hierarchy works (Core Value → Milestone → back)

**What Failed:**
- ❌ Action checkboxes not responding - cannot mark complete [td-d1a25b]
- ⚠️ "Healthy Relationships" appears twice in Core Values list [td-d5cf5c]
- ❌ Habit day circles still not interactive (confirmed in milestone view)

**Key Insight:**
Navigation and view rendering work well. The app successfully displays hierarchical data (Core Values → Milestones → Actions/Habits). However, all interactive check-in/completion features remain non-functional across all views.

## Priorities for Next Test Sessions

1. **High Priority** - Core happy paths:
   - Onboarding flow (first-time user experience)
   - Create core value → create milestone → create habit
   - Today view navigation and date selection
   - Habit daily check-in flow

2. **Medium Priority** - Secondary features:
   - Milestone filtering (By Value / By Date)
   - Action creation and completion
   - Settings configuration
   - Edit/delete operations

3. **Low Priority** - Edge cases and polish:
   - Validation error messages
   - Accessibility compliance
   - Performance with large datasets
   - Visual consistency across views

## Testing Guidelines for Testing Agents

### Testing Approach for iOS Apps

**✅ DO: UI Testing on Real Simulators**

Testing agents MUST perform real-world UI testing using iOS Simulator instances, NOT automated XCTest suites. This approach:

1. **Connect to iOS Simulator**
   - Use `mcp__mobile__list_devices` to find available simulators
   - Use `mcp__mobile__set_device` to select the target simulator
   - Launch the app in the simulator if not already running

2. **Interact Like a Real User**
   - Use `mcp__mobile__screenshot` to see the current UI state
   - Use `mcp__mobile__tap` to click buttons, fields, and UI elements
   - Use `mcp__mobile__input_text` to enter text in forms
   - Use `mcp__mobile__swipe` to scroll and navigate
   - Use `mcp__mobile__get_ui` to inspect the UI hierarchy when needed

3. **Test Real-World Usability**
   - Follow actual user flows (onboarding → create value → create milestone → check habit)
   - Test edge cases by entering unusual values
   - Verify visual states, error messages, and user feedback
   - Test navigation patterns and user journeys
   - Report usability issues, confusing UX, or visual bugs

4. **Document Findings**
   - Take screenshots at key steps for reproduction
   - **CRITICAL**: Add all bugs to the task system using `td add` command with appropriate priority and labels
     - Example: `td add "Bug description" --priority critical --labels bug,ui,feature-name`
     - Use labels: `bug` (required), plus feature area labels like `habits`, `calendar`, `navigation`, `ui`, etc.
     - Set priority: `critical` (P0), `high` (P1), `medium` (P2), `low` (P3)
   - Update the Coverage Status table in this document
   - Update the Test History session log with task IDs created
   - Reference td task IDs (e.g., [td-abc123]) when noting issues in test sessions
   - Document testing facts (device, iOS version, what worked/failed) in test session log
   - Note insights and recommendations in test session log

**❌ DON'T: Run Automated XCTest Suites**

Testing agents should NOT use:
- `xcodebuild test` commands
- XCTest unit test suites
- Automated test runners

These are for developers to run during development. Testing agents provide value by:
- Finding usability issues automation can't catch
- Testing real user journeys
- Discovering edge cases through exploration
- Validating the actual user experience

### General Guidelines

- Always test on a clean simulator state when possible (or document existing data)
- Document iOS version and device model in bug reports
- Take screenshots at key steps for reproduction
- Update this plan after each test session
- Link all findings to `td` tasks for tracking
- Focus on user experience, not implementation details
