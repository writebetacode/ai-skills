---
name: prune-branches
description: Delete local branches whose commits are fully merged into main. Use when you want to clean up stale local branches.
model: sonnet
---

# Prune Branches: Clean Up Merged Local Branches

## Workflow

1. **Discover**: Run `git fetch --prune` then list local branches with
   `git branch --merged main` to find fully-merged candidates. Exclude `main`, `master`, and the current branch.
2. **Review**: Show the list of branches to delete. If none, report clean and stop.
3. **Confirm**: Ask `Delete these branches? (yes/no)`.
4. **Execute**: Delete each with `git branch -d <branch>`.
5. **Report**: List deleted branches and any that failed.

## Rules

- Never delete main, master, or the currently checked-out branch
- Never use -D (force delete) — only -d
- Never delete without user confirmation
- Always fetch before checking merged status

## User Input

$ARGUMENTS
