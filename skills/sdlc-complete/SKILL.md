---
name: sdlc-complete
description: Archive a finished project. Use after all epics are Complete to move the project folder to plans/complete/ with a date-stamped name and clean up its local branches.
---

# Complete

Flow: design -> implement -> **[complete]**

Resolve target from `$ARGUMENTS`, a task file path, or prompt user.

## Workflow

Resolve the target to the project folder containing `MANIFEST.md`; if given an epic or task path, walk up to the project root. Read the manifest, check whether all epics are "Complete". If so, present source and target archival paths for confirmation. If some remain incomplete, list them and ask whether to proceed anyway. Move the entire project folder — manifest, research, epics, tasks, supporting files — to `plans/complete/YYYYMMDD-<project-slug>/` (today's date). Date appends at archive time so the original slug can be reused without collision.

After archiving, collect branch names from each task file's `Branch` field. Switch to `main` if needed. For each branch, verify its changes are in main via a quiet diff between merge base and branch tip — squash merges leave `git branch -d` reporting "not merged", so ancestry alone cannot decide. If the diff is empty, delete with `git branch -D`; otherwise warn and skip. Final report: deleted branches (and any skipped with reasons), total epics, total tasks completed, timeline from manifest creation to completion.

## Rules

Never archive without explicit confirmation. Warn for incomplete tasks rather than skipping silently. Delete a branch only after its diff against main is verified empty; warn and skip otherwise. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
