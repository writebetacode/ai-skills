---
name: prune-branches
description: Delete local branches whose commits are fully merged into main. Use when you want to clean up stale local branches.
model: sonnet
---

# Prune Branches: Clean Up Merged Local Branches

## Workflow

1. **Discover**: Run `git fetch --prune`. Then for each local branch (excluding `main`, `master`, and the current branch), run `git diff main...<branch> --quiet` — if the diff is empty, the branch's changes are already in main (handles both regular and squash merges). Collect all such branches as candidates.
2. **Review**: Show the list of branches to delete. If none, report clean and stop.
3. **Confirm**: Ask `Delete these branches? (yes/no)`.
4. **Execute**: Delete each with `git branch -D <branch>` (force required since squash-merged branches are not in `--merged`).
5. **Report**: List deleted branches and any that failed.

## Rules

- Never delete main, master, or the currently checked-out branch
- Only use -D after confirming the diff is empty — never force-delete branches with unmerged changes
- Never delete without user confirmation
- Always fetch before checking merged status

## User Input

$ARGUMENTS
