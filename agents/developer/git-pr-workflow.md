# Git Branch + PR Workflow (Developer Agents)

**Audience**: Developer agents implementing features, fixing bugs, and writing code.

Use this guide before coding and during final task closeout.

## Before coding
1. Sync from GitHub (`git fetch origin` and/or `git pull --ff-only`).
2. Confirm `gh` exists (`command -v gh`).
3. If sync fails or `gh` is missing, stop and report blocker.

## Worktree setup (mandatory)
All implementation work **must** run inside a dedicated Git worktree — never directly in the main repository directory. This keeps parallel tasks isolated from one another.

1. From the main repository root, create the worktree and branch together:
   ```
   git worktree add ../rallyops-wt/<td-id> -b <branch-name>
   ```
   Example: `git worktree add ../rallyops-wt/td-123abc -b feat/td-123abc-edit-habit-fix`

2. Do **all** implementation work from within `../rallyops-wt/<td-id>/`.

The worktree and local branch are removed automatically by the pr-webhook when the PR merges. If you need to clean up manually: `git worktree remove ../rallyops-wt/<td-id>`.

## Branch naming
- Standard work: `<type>/<td-id>-<short-kebab-title>`
- `<type>` is one of `feat`, `fix`, `chore`, `hotfix`
- Example: `feat/td-123abc-edit-habit-fix`

## One task per branch
- Never mix multiple task IDs in one branch.
- One branch maps to one task and one worktree.

## Closeout (PR required for all tasks)
Work from within the task worktree (`../rallyops-wt/<td-id>/`):
1. Commit on task branch.
2. Push branch: `git push -u origin <branch>`.
3. Create PR to `main` using `gh pr create`.
4. Enable auto-merge so it merges without manual intervention:
   `gh pr merge --auto --squash <number>`
5. After PR exists, mark task review-ready via `td review <id>`.

Note: `td approve` and worktree/branch cleanup run automatically via the pr-webhook server when the PR merges.
Do not run `td approve` manually.

## Post-merge cleanup
The pr-webhook automatically handles all cleanup on merge:
- Runs `td approve <id>`
- Removes the worktree at `../rallyops-wt/<td-id>`
- Deletes the local task branch
- Syncs local `main` to `origin/main`

If the webhook did not run (e.g., server was offline), clean up manually from the main repository root:
1. `git worktree remove ../rallyops-wt/<td-id>`
2. `git checkout main && git pull --ff-only`
3. `git branch -d <branch>`
