# Issue Reporting (Testing Agents)

**Audience**: Testing agents creating tasks for bugs, improvements, and enhancements.

Use this guide when creating `td` tasks for test findings.

## Core Principle

**Every finding gets a task.** Even minor polish items should be documented so they can be prioritized and tracked.

## Task Types

### Bug (`--type bug`)
**When**: Feature doesn't work as documented or expected
**Priority**: Based on severity and user impact

```bash
td create "Milestone deadline validation allows past dates" \
  --type bug \
  --priority P1 \
  --description "**Reproduction Steps:**
1. Navigate to Milestones tab
2. Tap '+' to create new milestone
3. Set deadline to yesterday's date
4. Tap Save

**Expected:** Validation error per docs/milestones.md: \"deadline must be in the future\"
**Actual:** Milestone saves successfully with past date
**Impact:** Users can create invalid milestones that are already overdue
**Tested on:** iPhone 16e Simulator, iOS 18.2"
```

### Feature Request (`--type feature`)
**When**: Missing functionality that would improve user experience
**Priority**: Based on user value and competitive analysis

```bash
td create "Add quick date selection for milestone deadlines" \
  --type feature \
  --priority P3 \
  --description "**Current State:**
Users must manually navigate calendar to select deadline dates.

**Proposed Enhancement:**
Add quick-select buttons above calendar picker:
- Today
- This Weekend
- Next Week
- Next Month

**Rationale:**
- Competitors (Streaks, Way of Life) provide this
- Reduces friction for common deadline patterns
- Observed user confusion during testing when picking dates far in future

**Reference:**
Competitive analysis: docs/competitive-analysis.md"
```

### Polish/Improvement (`--type chore`)
**When**: Minor UX improvements, visual inconsistencies, or accessibility enhancements
**Priority**: Usually P3 or P4

```bash
td create "Add haptic feedback on habit completion" \
  --type chore \
  --priority P3 \
  --labels accessibility,polish \
  --minor \
  --description "**Current State:**
No haptic feedback when tapping habit day circles.

**Proposed:**
Add light haptic feedback (UIImpactFeedbackGenerator.light) on:
- Marking habit as complete
- Unmarking habit

**Benefit:**
- Improves perceived responsiveness
- Standard iOS pattern for toggle actions
- Accessibility benefit for users who rely on haptic cues

**Reference:**
- iOS HIG: Haptic Feedback
- Competitor: Streaks app uses this pattern"
```

## Priority Guidelines

### P0 - Critical (Rare)
- App crashes or data loss
- Core functionality completely broken
- Security/privacy issues
**Example:** "App crashes when creating first milestone"

### P1 - High
- Major feature broken or significantly degraded
- Validation failures allowing invalid data
- User can't complete primary workflows
**Example:** "Past milestone deadlines accepted despite validation"

### P2 - Medium
- Minor feature broken
- Workarounds exist but inconvenient
- UX confusion causing common user errors
**Example:** "No visual feedback when Save button disabled"

### P3 - Low
- Polish, minor improvements
- Accessibility enhancements
- Features working but could be better
**Example:** "Add haptic feedback on completion"

### P4 - Nice-to-Have
- Cosmetic issues
- Very minor inconsistencies
- Future enhancements with unclear value
**Example:** "Consider adding celebration animation on streak milestones"

## Labels

Use labels to categorize and filter tasks:

### Functional Categories
- `testing` - Found during testing
- `ux` - User experience issue
- `accessibility` - Accessibility concern
- `performance` - Speed/responsiveness issue
- `validation` - Data validation problem

### Feature Areas
- `habits`, `milestones`, `actions`, `core-values`, `today-view`, `calendar`, `settings`, `onboarding`

### Quality Categories
- `polish` - Visual/UX refinement
- `consistency` - Inconsistent behavior/styling
- `edge-case` - Rare scenario handling

**Example:**
```bash
td create "VoiceOver labels missing on habit day circles" \
  --type bug \
  --priority P2 \
  --labels accessibility,habits,testing
```

## Task Relationships

### Blocking Dependencies
When a bug prevents testing other areas:

```bash
# Create blocker task first
td create "Calendar picker crashes when selecting future year" \
  --type bug \
  --priority P1

# Then create blocked task
td create "Test milestone creation with various deadline dates" \
  --type task \
  --depends-on TD-XXX \
  --description "Blocked by calendar picker bug. Cannot test deadline selection until fixed."
```

### Related Tasks
When multiple findings relate to the same feature area:

```bash
# Create parent epic for major feature work
td create "Milestone Creation UX Improvements" \
  --type epic \
  --priority P2

# Create child tasks
td create "Add quick date selection buttons" \
  --type feature \
  --parent TD-XXX

td create "Add visual feedback for validation errors" \
  --type chore \
  --parent TD-XXX
```

### Minor Issue Batching
For very minor polish items, batch under a shared epic:

```bash
# Check if Q1 polish epic exists
td list --type epic --search "polish"

# If not, create it
td create "Q1 2026 UX Polish & Consistency" \
  --type epic \
  --priority P3

# Add minor items as children
td create "Inconsistent button styling in settings" \
  --type chore \
  --parent TD-XXX \
  --minor \
  --priority P4
```

## Writing Effective Task Descriptions

### Bug Reports Must Include

1. **Reproduction Steps** (numbered, specific)
2. **Expected Behavior** (reference docs when possible)
3. **Actual Behavior** (what happened instead)
4. **Impact** (why this matters to users)
5. **Environment** (device, OS version)

### Feature Requests Must Include

1. **Current State** (what exists today)
2. **Proposed Enhancement** (specific suggestion)
3. **Rationale** (why this improves UX)
4. **Reference** (competitive analysis, user feedback, etc.)

### Polish/Chore Tasks Must Include

1. **Current State** (what needs improvement)
2. **Proposed Change** (specific improvement)
3. **Benefit** (user or system value)
4. **Reference** (HIG, competitor examples, etc.)

## Competitive Analysis Tasks

When documenting competitive insights:

```bash
td create "Consider adding habit streak visualization" \
  --type feature \
  --priority P3 \
  --labels competitive,habits \
  --description "**Competitive Analysis:**

**Streaks App:**
- Shows current streak count next to each habit
- Visual indicator (fire emoji) for active streaks
- Celebratory animation when extending streak

**Way of Life:**
- Streak counter with days/weeks/months
- Chart showing consistency over time
- Milestone markers at 7/30/100 days

**Proposal:**
Add streak counter to habit day circles showing consecutive days completed.

**Value:**
- Gamification increases engagement
- Visual progress motivator
- Industry standard pattern

**Reference:**
docs/competitive-analysis.md - Habit Tracking Features"
```

## Task Naming Conventions

### Good Task Titles
✅ "Milestone deadline validation allows past dates"
✅ "Add haptic feedback on habit completion"
✅ "VoiceOver label missing on 'Add Action' button"
✅ "Calendar picker shows dates outside valid range"

### Poor Task Titles
❌ "Bug in milestones" (too vague)
❌ "Fix the calendar" (unclear what's broken)
❌ "Improve UX" (not specific)
❌ "Testing found issues" (unhelpful summary)

**Title Formula:**
`[Component/Feature] [specific issue or enhancement]`

## Self-Review and Minor Flag

Testing agents can mark tasks as `--minor` for trivial items that don't require full review:

```bash
td create "Update placeholder text in milestone name field" \
  --type chore \
  --minor \
  --priority P4 \
  --description "Current: 'Enter name'
Suggested: 'e.g., Run a marathon'

More helpful example text guides users."
```

**Use `--minor` for:**
- Typo fixes in UI text
- Placeholder text improvements
- Very small visual adjustments
- Documentation updates

**Don't use `--minor` for:**
- Bugs (even small ones)
- Validation changes
- Behavioral changes
- Anything touching business logic

## Session Workflow Example

```bash
# 1. Start testing session
td usage --new-session
td usage -q

# 2. During testing, create tasks as you find issues
td create "..." --type bug --priority P1
td create "..." --type feature --priority P3
td create "..." --type chore --priority P4

# 3. Review created tasks
td list --labels testing | grep "$(date +%Y-%m-%d)"

# 4. Verify all findings documented
td status
```

## Quality Checklist

Before ending a test session, verify each task:
- [ ] Has clear, actionable title
- [ ] Includes reproduction steps (bugs) or rationale (features)
- [ ] Has appropriate type (bug/feature/chore)
- [ ] Has realistic priority (P0-P4)
- [ ] Has relevant labels
- [ ] References documentation or competitive analysis where applicable
- [ ] Uses `--minor` flag only for truly trivial items

## Common Patterns

### Accessibility Issues
```bash
td create "VoiceOver: [specific element] missing label" \
  --type bug \
  --priority P2 \
  --labels accessibility,testing
```

### Validation Bugs
```bash
td create "[Feature] validation: [specific rule] not enforced" \
  --type bug \
  --priority P1 \
  --labels validation,testing
```

### Visual Inconsistencies
```bash
td create "[Component] styling inconsistent with [other component]" \
  --type chore \
  --priority P3 \
  --labels polish,consistency
```

### Missing Feedback
```bash
td create "No visual feedback when [user action]" \
  --type chore \
  --priority P2 \
  --labels ux,polish
```

## Anti-Patterns to Avoid

❌ **Don't create duplicate tasks**
- Search first: `td search "[keyword]"`
- If exists, add comment instead: `td comment TD-XXX "Confirmed still present in testing"`

❌ **Don't create implementation tasks**
- Testing agents identify problems, not solutions
- Bad: "Refactor MilestoneValidator to check deadline > now"
- Good: "Milestone deadline validation allows past dates"

❌ **Don't batch unrelated issues**
- Each distinct issue gets its own task
- Use epics/parent tasks to group related work

❌ **Don't use vague descriptions**
- Always include specific steps, examples, or references
- "Button doesn't work" → "Save button remains disabled after all fields completed"

## Reference Commands

```bash
# Search for existing issues
td search "milestone deadline"

# List recent testing tasks
td list --labels testing

# Show task details
td show TD-XXX

# Add comment to existing task
td comment TD-XXX "Retested on iPhone 16 Pro - still present"

# Update task priority
td update TD-XXX --priority P1

# Link tasks
td dep TD-XXX --blocks TD-YYY
```
