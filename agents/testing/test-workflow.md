# Test Workflow (Testing Agents)

**Audience**: Testing agents validating features, identifying UX issues, and ensuring quality.

Use this guide when planning, executing, and documenting test sessions.

## Session Setup

1. `td usage --new-session` (once per conversation or after `/clear`)
2. `td usage -q`
3. Read `docs/test-plan.md` to understand:
   - Current test coverage status
   - Areas needing testing
   - Recently changed features (priority targets)
4. Review recent git changes: `git diff main --name-only`

## Test Selection Strategy

Choose test focus using this priority order:

1. **Regression Testing** (Highest Priority)
   - Recently changed features from git diff
   - Areas with recent bug fixes
   - Features with open `td` tasks

2. **Untested Features** (High Priority)
   - Features marked "Never" or "Partial" in test plan
   - New features not yet documented in test plan

3. **End-to-End Flows** (Medium Priority)
   - Complete user journeys (e.g., onboarding → create value → create milestone → track habit)
   - Perform 1 E2E test per 5 focused tests

4. **Competitive Analysis** (Low Priority)
   - Compare specific features against competitor apps
   - Document findings in `docs/competitive-analysis.md`

## Test Execution Loop

### 1. Initialize Simulator
```bash
# List available iOS simulators
# Verify device is booted or boot it
# Set as active device
```

### 2. Navigate to Test Area
- Start from app home state
- Navigate as a real user would (no shortcuts)
- Take screenshots at each major step
- Document the navigation path

### 3. Test Scenarios
For each feature area, validate:

**✅ Functional Correctness**
- Does the feature work as documented?
- Are validation rules enforced? (e.g., past dates rejected)
- Does data persist correctly?
- Are edge cases handled? (empty states, maximum values, etc.)

**🎨 Visual & UX Quality**
- Is the UI clear and intuitive?
- Are tap targets appropriately sized (44x44pt minimum)?
- Is text readable and properly sized?
- Are colors/contrast sufficient for accessibility?
- Is spacing consistent with iOS HIG?

**🚦 User Flow Efficiency**
- Are there unnecessary steps?
- Is feedback immediate and clear?
- Are error messages helpful and actionable?
- Can users easily undo or correct mistakes?

**📱 Modern Standards**
- Compare against iOS Human Interface Guidelines
- Check VoiceOver labels (accessibility)
- Verify haptic feedback where appropriate
- Check for Dynamic Type support

### 4. Document Findings
Create structured notes for the session:

```markdown
## Test Session: [Feature/Area]
**Date**: YYYY-MM-DD
**Tester**: [Agent ID]
**Duration**: [X minutes]
**Coverage**: [Specific area tested]

### Navigation Path
1. [Step 1]
2. [Step 2]
...

### ✅ Verified Behaviors
- [Expected behavior that works correctly]
- [Another verified behavior]

### ❌ Bugs Found
- [Bug description with reproduction steps]
  - Expected: [What should happen]
  - Actual: [What actually happens]
  - Severity: P0/P1/P2/P3/P4

### 💡 Improvement Opportunities
- [Suggestion for UX enhancement]
- [Missing feature that would improve experience]

### 📊 Competitive Insights
- [Competitor]: [Feature/approach they use]
- Consider: [How this could apply to our app]

### 🎯 Follow-up Actions
- [TD-XXX] Bug: [Title]
- [TD-YYY] Feature: [Title]
- [TD-ZZZ] Chore: [Title]
```

### 5. Create `td` Tasks
For each finding, create appropriate tasks:
- See `agents/testing/issue-reporting.md` for guidance
- Use proper types: `bug`, `feature`, `chore`
- Set appropriate priorities: P0-P4
- Include reproduction steps and screenshots

### 6. Update Test Plan
```markdown
# In docs/test-plan.md:
- Mark tested area as "✅ Full" or "⚠️ Partial"
- Update "Last Tested" date
- Add/update test scenarios
- Link to created tasks in "Issues" column
```

## Test Session Scope

**Focused Testing** (Recommended: 80% of sessions)
- Deep dive into 1-2 related features
- Test 5-10 specific scenarios
- Duration: 15-30 minutes

**End-to-End Testing** (Recommended: 20% of sessions)
- Complete user journey from start to finish
- Test integration between features
- Duration: 30-60 minutes

## Quality Standards

### Minimum Testing Requirements
Each test session must:
- [ ] Test ≥3 specific scenarios
- [ ] Take ≥2 screenshots documenting the flow
- [ ] Create ≥1 `td` task (even if just documentation)
- [ ] Update test-plan.md with coverage status

### Exit Criteria
Before ending a test session:
1. All findings documented in structured notes
2. All bugs/improvements have `td` tasks created
3. Test plan updated with coverage and results
4. Session summary generated (can be added as comment to test plan)

## Session Closeout

```bash
# 1. Verify all tasks created
td list --labels testing

# 2. Check session status
td status

# 3. Add session summary as note
td note create "Test Session Summary: [Area]" --body "$(cat session-notes.md)"
```

## Continuous Improvement

After every 5 test sessions, review:
- Which areas have the most bugs? → Test more frequently
- Which docs are outdated/incorrect? → Create tasks to update them
- Which competitor features are mentioned repeatedly? → Discuss prioritization
- Which test scenarios catch the most issues? → Expand similar coverage

## Tools & References

**iOS Simulator Controls**
- Screenshots: Capture current state
- UI Inspection: View accessibility tree
- Navigation: Tap, swipe, type, long-press
- System: Home button, device rotation, notifications

**Documentation References**
- Feature docs: `docs/[feature].md`
- Test plan: `docs/test-plan.md`
- Competitive analysis: `docs/competitive-analysis.md`
- iOS HIG: https://developer.apple.com/design/human-interface-guidelines/

**Task Management**
- Issue creation: `agents/testing/issue-reporting.md`
- Task query: `td list`, `td show`, `td search`
- Session tracking: `td status`, `td current`
