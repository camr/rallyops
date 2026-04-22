# Agent Documentation

This directory contains workflow documentation for AI agents working on the RallyOps app.

## Agent Types

### Developer Agents (`agents/developer/`)
Agents that implement features, fix bugs, and write code.

**Key Workflows:**
- `td-workflow.md` - Task lifecycle (start, log, handoff, review)
- `git-pr-workflow.md` - Branch naming and PR creation
- `review-closeout.md` - Final review and handoff process

**Responsibilities:**
- Write code to implement features
- Fix bugs
- Create git commits and pull requests
- Follow one-task-per-branch discipline

---

### Testing Agents (`agents/testing/`)
Agents that validate features, identify UX issues, and ensure quality.

**Key Workflows:**
- `test-workflow.md` - Test planning, execution, and documentation
- `issue-reporting.md` - Creating `td` tasks for findings

**Responsibilities:**
- Execute functional and UX testing
- Identify bugs, improvements, and enhancements
- Document findings in test plan
- Create `td` tasks for all issues found
- Maintain competitive analysis
- **Never write code** - only identify problems

---

## Quick Start

### I'm a Developer Agent
1. Read `AGENTS.md` → Developer Agent Workflow section
2. Follow `developer/td-workflow.md` to start a task
3. Use `developer/git-pr-workflow.md` before making any code changes
4. Complete with `developer/review-closeout.md` when ready for review

### I'm a Testing Agent
1. Read `AGENTS.md` → Testing Agent Workflow section
2. Follow `testing/test-workflow.md` to plan and execute tests
3. Use `testing/issue-reporting.md` to document findings as `td` tasks
4. Update `docs/test-plan.md` after each session

---

## Key Differences

| Aspect | Developer Agents | Testing Agents |
|--------|------------------|----------------|
| **Primary Output** | Code, commits, PRs | Bug reports, test documentation |
| **Git Usage** | Create branches, commit, push, PR | Read-only (git diff, git log) |
| **TD Tasks** | Start/complete existing tasks | Create new tasks from findings |
| **PR Workflow** | Required for all work | Never create PRs |
| **Code Changes** | Expected and required | Forbidden |
| **Documentation** | Update related to code changes | Update test-plan.md and competitive-analysis.md |

---

## Common Commands

### Developer Agents
```bash
# Session start
td usage --new-session
td usage -q
td next

# Work on task
td start TD-XXX
# ... write code ...
td log TD-XXX "Implemented feature X"
td handoff TD-XXX

# Create PR
git add .
git commit -m "feat: ..."
git push -u origin feat/td-xxx-description
gh pr create
td review TD-XXX
```

### Testing Agents
```bash
# Session start
td usage --new-session
td usage -q
cat docs/test-plan.md

# Execute tests
# ... test in simulator ...

# Report findings
td create "Bug title" --type bug --priority P1 --description "..."
td create "Feature request" --type feature --priority P3 --description "..."

# Update docs
# Edit docs/test-plan.md to mark coverage status
```

---

## Documentation Index

### Developer Resources
- `developer/td-workflow.md` - Task lifecycle
- `developer/git-pr-workflow.md` - Git and PR process
- `developer/review-closeout.md` - Review handoff
- `docs/architecture.md` - App structure and data models
- `docs/*.md` - Feature specifications

### Testing Resources
- `testing/test-workflow.md` - How to test
- `testing/issue-reporting.md` - How to report issues
- `docs/test-plan.md` - What to test (coverage tracking)
- `docs/competitive-analysis.md` - Competitor benchmarking
- `docs/*.md` - Feature specifications (expected behavior)

---

## Need Help?

- **Lost?** Start with `AGENTS.md` in the repository root
- **Don't know what to work on?**
  - Developer: Run `td next` to get highest-priority task
  - Testing: Check `docs/test-plan.md` for untested areas
- **Confused about workflow?**
  - Developer: Re-read `developer/td-workflow.md`
  - Testing: Re-read `testing/test-workflow.md`
