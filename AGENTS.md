# Agent Instructions

Keep this file short. Open only the referenced document needed for the current step.

## Agent Types

This project uses two types of agents with distinct workflows:

### Developer Agents
Agents that implement features, fix bugs, and write code. See `agents/developer/` for workflows.

### Testing Agents
Agents that validate features, identify UX issues, and ensure quality. See `agents/testing/` for workflows.

---

## Developer Agent Workflow

### Required at session start
- Run `td usage --new-session` once at the start of a conversation (or after `/clear`).
- Then run `td usage -q`.

### Workflow references
- Task lifecycle with `td` (start, log, handoff, review):
  - See `agents/developer/td-workflow.md`
  - Use when selecting/working/completing tasks.
- Branching, push, and PR policy:
  - See `agents/developer/git-pr-workflow.md`
  - Use before any code edits and during closeout.
- Review-ready and commit message expectations:
  - See `agents/developer/review-closeout.md`
  - Use when preparing the final commit and marking ready for review.

### Global rules
- Use a sub-agent for work performed on each task.
- One task per branch and one task per PR.

---

## Testing Agent Workflow

### Required at session start
- Run `td usage --new-session` once at the start of a conversation (or after `/clear`).
- Then run `td usage -q`.
- Read `docs/test-plan.md` to understand current test coverage.

### Workflow references
- Test execution and documentation:
  - See `agents/testing/test-workflow.md`
  - Use when planning and executing tests.
- Issue reporting with `td`:
  - See `agents/testing/issue-reporting.md`
  - Use when creating tasks for bugs, improvements, and enhancements.
- Test plan maintenance:
  - See `docs/test-plan.md`
  - Update after each test session.

### Global rules
- Focus on user experience, not implementation details.
- Create `td` tasks for all findings (bugs, improvements, competitive insights).
- Never make code changes directly.
- Update test coverage documentation after each session.

## Commit Message Format
This project enforces conventional commits format via a git commit-msg hook.

**Format**: `type(scope): description`

**Required Types**:
- `feat`: New feature or functionality
- `fix`: Bug fix
- `chore`: Maintenance, dependencies, configs (no production code change)
- `refactor`: Code restructuring without changing behavior
- `docs`: Documentation only
- `test`: Adding or updating tests
- `style`: Formatting, whitespace, code style (no logic change)

**Examples**:
- `feat: add milestone completion tracking`
- `fix: resolve calendar view naming conflict`
- `chore: update dependencies`
- `refactor(models): simplify Core Value data structure`

**Style Guidelines**:
- Description should start with a lowercase letter for consistency
- Use imperative mood in descriptions (e.g., "add feature" not "adds feature")
- Keep descriptions concise and clear

**Auto-normalization**: The commit-msg hook automatically converts imperative mood messages to conventional format:
- Infers type from keywords (e.g., "Add feature" → `feat: feature`, "Fix bug" → `fix: bug`, "Remove config" → `chore: config`, "Rename method" → `refactor: method`)
- Removes the inferred keyword from the description to avoid duplication
- Lowercases the first letter of the description for consistency
- Preserves multi-line commit messages (body and trailers)
- Skips messages that already use conventional format
- Skips fixup, squash, and amend commits

**Installation**: To install the commit-msg hook, run the setup script:
```bash
scripts/setup-hooks.sh
```
