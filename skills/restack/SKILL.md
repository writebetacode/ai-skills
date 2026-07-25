---
name: restack
description: Rebase open branches onto the latest main — whether their intermediate base was squash-merged or main itself has new commits they are missing. Use when branches are out of sync with main for any reason.
---

# Restack

**Plan mode** (`$ARGUMENTS` is an epic directory containing `plan.md`): read `plan.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode** (`$ARGUMENTS` is empty): run `git branch -r --merged origin/main` to identify merged branches, then find open downstream branches built on them.

## Workflow

Run `git fetch origin` — never `git pull`, which would merge `origin/main` into whatever branch is currently checked out; every comparison below uses `origin/main` directly. Build two lists of open branches: *stacked* — base appears in `git branch -r --merged origin/main`; *behind* — `git merge-base origin/main <branch>` differs from `git rev-parse origin/main`. Stop only if both are empty. Present the full rebase sequence and ask `Proceed? (yes/no)`. Stacked: `git rebase --onto origin/main <old-base-tip> <branch>`. Behind-only: `git rebase origin/main <branch>`.

Rebase each open branch in stack order: record old base tip with `git rev-parse <old-base>` — the local ref, before any checkout; a squash-merged base is usually deleted upstream, so `origin/<old-base>` no longer resolves after the initial fetch. Then check out and rebase. On conflict, tell the user to resolve and run `git rebase --continue`, then re-run `/restack`. After each successful rebase, ask `Force-push <branch>? (yes/no)`; if confirmed, `git push --force-with-lease origin <branch>`. If the old base was a merged intermediate (not main), verify its changes are in main via a quiet diff between `git merge-base origin/main <old-base>` and the local `<old-base>` tip (squash merges leave `git branch -d` reporting "not merged"); if empty, delete with `git branch -D <old-base>`, otherwise warn and keep it. If a PR exists, offer to update its base with `gh pr edit <branch> --base <new-base>`. Summarize rebased, pushed, and PR bases updated.

## Rules

Always push with `--force-with-lease`, never without per-branch confirmation. Never rebase branches already merged into main. Rebase in stack order; stop immediately on conflict without skipping ahead. Delete an old base only after its diff against origin/main is verified empty — never on ancestry alone. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
