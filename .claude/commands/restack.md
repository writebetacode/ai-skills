---
name: restack
description: Rebase open branches onto the latest main — whether their intermediate base was squash-merged or main itself has new commits they are missing. Use when branches are out of sync with main for any reason.
model: sonnet
---

# Restack: Sync Open Branches After Squash Merge

**Plan mode** (`$ARGUMENTS` is a directory): read `index.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode** (`$ARGUMENTS` is empty): run `git branch -r --merged origin/main` to identify merged branches, then find open downstream branches that built on them.

## Workflow

1. **Fetch**: `git fetch origin && git pull origin main`
2. **Identify**: Build two lists of open branches that need rebasing:
   - *Stacked*: branches whose base appears in `git branch -r --merged origin/main`
   - *Behind*: branches not in the merged list where `git merge-base origin/main <branch>` != `git rev-parse origin/main` (main has commits the branch lacks)
   Stop only if both lists are empty.
3. **Plan**: Show the full rebase sequence and ask `Proceed? (yes/no)`:
   - Stacked branches: `git rebase --onto origin/main <old-base-tip> <branch>`
   - Behind-only branches: `git rebase origin/main <branch>`
4. **Rebase each open branch in order**:
   - `git rev-parse origin/<old-base>` to record old base tip.
   - `git checkout <branch>`.
   - Run the rebase from the plan above.
   - On conflict: stop, tell user to resolve and run `git rebase --continue`, then re-run `/restack`.
   - Ask `Force-push <branch>? (yes/no)`. If yes: `git push --force-with-lease origin <branch>`.
   - If `<old-base>` was a merged intermediate branch (not main): `git branch -d <old-base>`.
   - If a PR exists for `<branch>`, offer to update its base: `gh pr edit <branch> --base <new-base>`.
5. **Report**: Summarize what was rebased/pushed and which PR bases were updated.
## Rules

- Use `--force-with-lease`, not `--force`
- Never rebase merged branches — only open ones
- Rebase in stack order — stop on conflict, never skip ahead
- Never push without per-branch confirmation
- `git branch -d` only (safe, not force)
- ASCII only, no AI attribution

## User Input

$ARGUMENTS
