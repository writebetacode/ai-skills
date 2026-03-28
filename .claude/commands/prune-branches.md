---
name: prune-branches
description: Delete local branches whose commits are fully merged into main. Use when you want to clean up stale local branches.
---

# Prune Branches: Clean Up Merged Local Branches

## Workflow

Start by running `git fetch --prune` to synchronize with the remote. For each local branch excluding `main`, `master`, and the current branch, check if its changes are already in main by running a quiet diff between the merge base and the branch tip; this accurately handles both regular and squash merges. Present the list of candidate branches to the user for review. If no branches are eligible for deletion, report that the workspace is clean and stop. Ask for explicit confirmation before deleting each confirmed branch using `git branch -D` to ensure squash-merged branches are properly removed. Finally, provide a summary report of all deleted branches and any that failed to be removed.

## Rules

Never delete the `main` or `master` branches, nor the currently checked-out branch. Only use the force-delete flag after confirming that the diff against main is empty to avoid losing unmerged changes. Never perform any deletions without explicit user confirmation and always fetch from the remote before checking the merged status of branches.

## User Input

$ARGUMENTS
