---
name: prune-branches
description: Delete local branches whose changes already landed in the repo's default branch, including squash-merged branches that `git branch -d` refuses as unmerged. Use when you want to clean up stale local branches.
---

# Prune Branches

## Workflow

Run `git fetch --prune`. Resolve the default branch — `git symbolic-ref --short refs/remotes/origin/HEAD` with the leading `origin/` stripped, falling back to `git remote show origin` parsed for `HEAD branch:` when that ref is absent or stale. Never assume `main`; a repo defaulting to `develop`, `master`, or `trunk` must compare against that. If neither method resolves, stop and ask the user which branch to compare against — deleting on a guessed default is how work is lost.

For each local branch excluding the default branch and the current branch, check whether its changes are already in the default branch via a quiet diff between merge base and branch tip — squash merges leave `git branch -d` reporting "not merged", so ancestry alone cannot decide. Present candidates and ask `Delete <branch>? (yes/no)` per branch; if none, report clean workspace and stop. Delete confirmed branches with `git branch -D`. Finish with a summary of deleted and failed.

## Rules

Never delete the resolved default branch, `main`, `master`, or the current branch. Never delete a branch without explicit per-branch confirmation, and never before its diff against the resolved default branch is verified empty — never on ancestry alone, never against an assumed `main`. Always fetch from remote first. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
