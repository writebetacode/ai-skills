---
name: prune-branches
description: Delete local branches whose changes already landed in main, including squash-merged branches that `git branch -d` refuses as unmerged. Use when you want to clean up stale local branches.
---

# Prune Branches

## Workflow

Run `git fetch --prune`. For each local branch excluding `main`, `master`, and the current branch, check whether its changes are already in main via a quiet diff between merge base and branch tip — squash merges leave `git branch -d` reporting "not merged", so ancestry alone cannot decide. Present candidates; if none, report clean workspace and stop. Delete confirmed branches with `git branch -D`. Finish with a summary of deleted and failed.

## Rules

Never delete `main`, `master`, or the current branch. Never delete a branch without explicit per-branch confirmation, and never before its diff against main is verified empty — never on ancestry alone. Always fetch from remote first. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
