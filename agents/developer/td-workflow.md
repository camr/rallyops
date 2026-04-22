# td Workflow (Developer Agents)

**Audience**: Developer agents implementing features, fixing bugs, and writing code.

Use this guide when starting, executing, and handing off a task.

## Session setup
1. `td usage --new-session` (once per conversation or after `/clear`)
2. `td usage -q`
3. `td next`

## Task execution
1. `td start <id>`
2. Do implementation work
3. `td log <id> "<progress update>"`
4. `td handoff <id>`

## Review handoff timing
- Do not run `td review <id>` until branch/PR requirements are complete.
- Follow `agents/developer/git-pr-workflow.md` first, then mark review-ready.
- After `td review <id>`, leave the task in `in_review` until the PR is merged.
- Do not run `td approve` from the implementer/coding session.

## Completion check
- Run `td current` and verify no task remains in progress before starting another one.
