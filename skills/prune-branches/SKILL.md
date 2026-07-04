---
name: prune-branches
description: Delete local branches whose commits are fully merged into main. Use when you want to clean up stale local branches.
model: sonnet
---

# Prune Branches

## Workflow

Run `git fetch --prune`. For each local branch excluding `main`, `master`, and the current branch, check if changes are already in main via a quiet diff between merge base and branch tip — handles regular and squash merges. Present candidates for review; if none, report clean workspace and stop. Get explicit confirmation per branch before deleting with `git branch -D` (handles squash-merged). Finish with a summary of deleted and failed.

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Never delete `main`, `master`, or the current branch. Only force-delete after confirming the diff against main is empty. Never delete without explicit confirmation; always fetch from remote first. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
