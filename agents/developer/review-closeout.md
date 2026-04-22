# Review Closeout (Developer Agents)

**Audience**: Developer agents implementing features, fixing bugs, and writing code.

Use this guide when finalizing work for reviewer handoff.

## Required order
1. `td handoff <id>`
2. Create commit(s) with clear title + short description body
3. Complete the branch/PR flow from `agents/developer/git-pr-workflow.md`
4. `td review <id>` only after the required Git step is done
5. Leave the task in `in_review` until the PR is merged
6. After merge, a separate reviewer/maintainer session runs `td approve <id>`
7. `td current` to verify no task remains in progress

## Commit message expectation
- Title: concise summary of change
- Description: short explanation of implementation

## Guardrails
- Do not start the next task before the current task is in `in_review`.
- Keep each task isolated to its own branch and review artifact.
- Never self-approve implementation tasks.
- Do NOT run `xcodebuild test` or any xcodebuild test commands. Tests are run by CI.
