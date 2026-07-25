---
name: restack
description: Rebase open branches onto the repo's latest default branch — whether their intermediate base was squash-merged or the default branch itself has new commits they are missing. Use when branches are out of sync for any reason.
---

# Restack

**Plan mode** (`$ARGUMENTS` is an epic directory containing `plan.md`): read `plan.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode** (`$ARGUMENTS` is empty): run `git branch -r --merged origin/<default>` to identify merged branches, then find open downstream branches built on them.

`<default>` below is the repo's default branch, not a literal `main`. Resolve it once up front with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:` when that ref is absent or stale. A repo defaulting to `develop`, `master`, or `trunk` rebases onto that instead. If neither method resolves, stop and ask rather than assuming.

## Workflow

Run `git fetch origin` — never `git pull`, which would merge `origin/<default>` into whatever branch is currently checked out; every comparison below uses `origin/<default>` directly. Build two lists of open branches: *stacked* — base appears in `git branch -r --merged origin/<default>`; *behind* — `git merge-base origin/<default> <branch>` differs from `git rev-parse origin/<default>`. Stop only if both are empty. Present the full rebase sequence and ask `Proceed? (yes/no)`. Stacked: `git rebase --onto origin/<default> <old-base-tip> <branch>`. Behind-only: `git rebase origin/<default> <branch>`.

Rebase each open branch in stack order: record old base tip with `git rev-parse <old-base>` — the local ref, before any checkout; a squash-merged base is usually deleted upstream, so `origin/<old-base>` no longer resolves after the initial fetch. Then check out and rebase. On conflict, tell the user to resolve and run `git rebase --continue`, then re-run `/restack`. After each successful rebase, ask `Force-push <branch>? (yes/no)`; if confirmed, `git push --force-with-lease origin <branch>`. If the old base was a merged intermediate (not the default branch), verify its changes are in the default branch via a quiet diff between `git merge-base origin/<default> <old-base>` and the local `<old-base>` tip (squash merges leave `git branch -d` reporting "not merged"); if empty, delete with `git branch -D <old-base>`, otherwise warn and keep it. If a PR exists, offer to update its base with `gh pr edit <branch> --base <new-base>`. Summarize rebased, pushed, and PR bases updated.

## Rules

Always push with `--force-with-lease`, never without per-branch confirmation. Never rebase branches already merged into the default branch. Rebase in stack order; stop immediately on conflict without skipping ahead. Delete an old base only after its diff against `origin/<default>` is verified empty — never on ancestry alone, never against an assumed `main`. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
