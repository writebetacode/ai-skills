---
name: restack
description: Rebase open branches onto the latest main — whether their intermediate base was squash-merged or main itself has new commits they are missing. Use when branches are out of sync with main for any reason.
---

# Restack: Sync Open Branches After Squash Merge

**Plan mode** (`$ARGUMENTS` is a directory): read `index.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode** (`$ARGUMENTS` is empty): run `git branch -r --merged origin/main` to identify merged branches, then find open downstream branches that built on them.

## Workflow

Begin by running `git fetch origin && git pull origin main`. Build two lists of open branches: *stacked* branches whose base appears in `git branch -r --merged origin/main`, and *behind* branches where `git merge-base origin/main <branch>` differs from `git rev-parse origin/main`. Stop only if both lists are empty. Present the full rebase sequence and ask `Proceed? (yes/no)` — stacked branches use `git rebase --onto origin/main <old-base-tip> <branch>`, behind-only branches use `git rebase origin/main <branch>`.

Rebase each open branch in order: record the old base tip with `git rev-parse origin/<old-base>`, check out the branch, and run the appropriate rebase. On conflict, stop immediately and tell the user to resolve it and run `git rebase --continue`, then re-run `/restack`. After each successful rebase, ask `Force-push <branch>? (yes/no)` and if confirmed use `git push --force-with-lease origin <branch>`. If the old base was a merged intermediate branch (not main), delete it with `git branch -d <old-base>`. If a PR exists for the branch, offer to update its base with `gh pr edit <branch> --base <new-base>`. Summarize what was rebased, pushed, and which PR bases were updated.

## Rules

Always use the `--force-with-lease` flag when pushing and never rebase branches that have already been merged into main. Perform all rebases in the correct stack order and stop immediately upon encountering a conflict without skipping ahead. Never push any changes without per-branch confirmation and only use the safe `git branch -d` command for deleting branches. Use only ASCII characters and never include AI attribution or "Co-Authored-By" lines in any output.

## User Input

$ARGUMENTS
