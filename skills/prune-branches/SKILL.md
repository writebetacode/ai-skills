---
name: prune-branches
description: Delete local branches whose commits are fully merged into main. Use when you want to clean up stale local branches.
model: sonnet
---

# Prune Branches: Clean Up Merged Local Branches

## Workflow

Run `git fetch --prune` to sync with the remote. For each local branch excluding `main`, `master`, and the current branch, check if its changes are already in main by running a quiet diff between the merge base and the branch tip — this handles both regular and squash merges. Present the candidate list to the user for review; if none are eligible, report a clean workspace and stop. Get explicit confirmation before deleting each confirmed branch with `git branch -D` so squash-merged branches are properly removed. Finish with a summary report of deleted branches and any that failed.

<!-- response-style:v1 — keep this block byte-identical across all skills; verify with `task verify:response-style`. -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Never delete `main`, `master`, or the currently checked-out branch. Only use the force-delete flag after confirming the diff against main is empty to avoid losing unmerged changes. Never delete without explicit user confirmation and always fetch from the remote first. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
