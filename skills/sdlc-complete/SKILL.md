---
name: sdlc-complete
description: Archive a finished SDLC project -- move its plans folder into plans/complete/ under a date-stamped name, then delete the local branches its tasks left behind. Use when a project is finished and being wrapped up, when the last task has merged and the plan folder should be put away, or when asking to clean up the branches a project left behind.
argument-hint: "[project-dir]"
---

# Complete

Flow: design -> implement -> **[complete]**

## Workflow

Resolve the target from the arguments, a task file path, or by prompting the user, landing on the project folder containing `MANIFEST.md`; if given an epic or task path, walk up to the project root. Read the manifest, check whether all epics are "Complete". If so, present the source and target archival paths. If some remain incomplete, list them and ask whether to proceed anyway. Move the entire project folder -- manifest, research, epics, tasks, supporting files -- to `plans/complete/YYYYMMDD-<project-slug>/` (today's date). Date appends at archive time so the original slug can be reused without collision.

After archiving, collect branch names from each task file's `Branch` field. Resolve the repo's default branch via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:`; never assume `main`, since the repo may default to `develop`, `master`, or `trunk`. Switch to it if needed. For each branch, verify its changes are in the default branch via a quiet diff between merge base and branch tip -- squash merges leave `git branch -d` reporting "not merged", so ancestry alone cannot decide. Delete an empty-diff branch with `git branch -D`. The permission layer asks before every branch deletion, so expect a prompt per branch and never work around it. Final report: deleted branches (and any skipped with reasons), total epics, total tasks completed, timeline from manifest creation to completion.

## Rules

Never archive without explicit confirmation. Never delete a branch whose diff against the resolved default branch is not verified empty -- warn and skip it instead. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
