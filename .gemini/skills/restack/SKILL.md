---
name: restack
description: Rebase open branches onto main after squash-merged PRs have caused conflicts in a stacked branch sequence. Use when PRs have been squash-merged and downstream branches have conflicts or duplicate commits.
---

# Restack: Sync Open Branches After Squash Merge

**Plan mode**: read `index.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode**: run `git branch -r --merged origin/main` to identify merged branches, then find open downstream branches that built on them.

## Workflow

1. **Fetch**: `git fetch origin && git pull origin main`
2. **Identify**: For each branch, check merged: `git branch -r --merged origin/main | grep <branch>`. Build merged list and open list. Stop if nothing is merged.
3. **Plan**: For each open branch, determine new base — `origin/main` if its original base was merged, else the updated upstream branch. Show the full sequence and ask `Proceed? (yes/no)`.
4. **Rebase each open branch in order**:
   - `git rev-parse origin/<old-base>` to record old base tip
   - `git checkout <branch>`
   - `git rebase --onto <new-base> <old-base-tip> <branch>`
   - On conflict: stop, tell user to resolve and run `git rebase --continue`, then re-run `restack`
   - Ask `Force-push <branch>? (yes/no)`. If yes: `git push --force-with-lease origin <branch>`
   - If `<old-base>` was a merged intermediate branch (not main): `git branch -d <old-base>`
   - If a PR exists for `<branch>`, offer to update its base: `gh pr edit <branch> --base <new-base>`
   5. **Report**: Summarize what was rebased/pushed and which PR bases were updated.
## Rules

- Use `--force-with-lease`, not `--force`
- Never rebase merged branches — only open ones
- Rebase in stack order — stop on conflict, never skip ahead
- Never push without per-branch confirmation
- `git branch -d` only (safe, not force)
- ASCII only, no AI attribution
