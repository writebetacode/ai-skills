---
name: prune-branches
description: Delete local branches whose changes already landed in main, including squash-merged branches that `git branch -d` refuses as unmerged. Use when you want to clean up stale local branches.
model: sonnet
---

# Prune Branches

## Workflow

Run `git fetch --prune`. For each local branch excluding `main`, `master`, and the current branch, check whether its changes are already in main via a quiet diff between merge base and branch tip — squash merges leave `git branch -d` reporting "not merged", so ancestry alone cannot decide. Present candidates; if none, report clean workspace and stop. Delete confirmed branches with `git branch -D`. Finish with a summary of deleted and failed.

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Never delete `main`, `master`, or the current branch. Never delete a branch without explicit per-branch confirmation, and never before its diff against main is verified empty — never on ancestry alone. Always fetch from remote first. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
