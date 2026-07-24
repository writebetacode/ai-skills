---
name: restack
description: Rebase open branches onto the latest main — whether their intermediate base was squash-merged or main itself has new commits they are missing. Use when branches are out of sync with main for any reason.
model: sonnet
---

# Restack

**Plan mode** (`$ARGUMENTS` is an epic directory containing `plan.md`): read `plan.md`, extract Branch/Base fields — this defines the stack order.
**Auto mode** (`$ARGUMENTS` is empty): run `git branch -r --merged origin/main` to identify merged branches, then find open downstream branches built on them.

## Workflow

Run `git fetch origin` — never `git pull`, which would merge `origin/main` into whatever branch is currently checked out; every comparison below uses `origin/main` directly. Build two lists of open branches: *stacked* — base appears in `git branch -r --merged origin/main`; *behind* — `git merge-base origin/main <branch>` differs from `git rev-parse origin/main`. Stop only if both are empty. Present the full rebase sequence and ask `Proceed? (yes/no)`. Stacked: `git rebase --onto origin/main <old-base-tip> <branch>`. Behind-only: `git rebase origin/main <branch>`.

Rebase each open branch in stack order: record old base tip with `git rev-parse origin/<old-base>`, check out, rebase. On conflict, tell the user to resolve and run `git rebase --continue`, then re-run `/restack`. After each successful rebase, ask `Force-push <branch>? (yes/no)`; if confirmed, `git push --force-with-lease origin <branch>`. If the old base was a merged intermediate (not main), verify its changes are in main via a quiet diff between `git merge-base origin/main <old-base>` and its tip (squash merges leave `git branch -d` reporting "not merged"); if empty, delete with `git branch -D <old-base>`, otherwise warn and keep it. If a PR exists, offer to update its base with `gh pr edit <branch> --base <new-base>`. Summarize rebased, pushed, and PR bases updated.

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Always push with `--force-with-lease`, never without per-branch confirmation. Never rebase branches already merged into main. Rebase in stack order; stop immediately on conflict without skipping ahead. Delete an old base only after its diff against origin/main is verified empty — never on ancestry alone. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
