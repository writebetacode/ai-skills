---
name: sdlc-complete
description: Archive a finished project. Use after all epics are Complete to move the project folder to plans/complete/ with a date-stamped name and clean up its local branches.
---

# Complete: Archive Finished Work

Flow: design -> implement -> **[complete]**

Resolve target from `$ARGUMENTS`, a task file path, or prompt user.

## Workflow

Resolve the target to the project folder containing `MANIFEST.md`; if given an individual epic or task path, walk up to the project root. Read the manifest and check whether all epics are marked "Complete". If so, present source and target archival paths and request explicit confirmation before proceeding. If some remain incomplete, list them and ask whether to proceed anyway. Move the entire project folder — manifest, research, epics, tasks, and all supporting files — to `plans/complete/YYYYMMDD-<project-slug>/` (today's date). The date appends at archive time so the original slug can be reused without collision.

After archiving, collect branch names from each task file's `Branch` field. Switch to `main` if needed, then delete each branch with `git branch -d`. On unmerged commits, warn and skip rather than force-delete. Final report covers deleted branches (and any skipped with reasons), total epics, total tasks completed, and the timeline from manifest creation to completion.

## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Never archive without explicit user confirmation. Warn for incomplete tasks rather than skipping silently. Only use the safe `git branch -d` — never force-delete. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
