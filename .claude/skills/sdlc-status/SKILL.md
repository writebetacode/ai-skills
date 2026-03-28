---
name: sdlc-status
description: Read the project manifest and show what is done, what is actionable, and what to do next. Use anytime you need to orient on a multi-epic project.
---

# Status: Project Dashboard

If `$ARGUMENTS` contains a path, use it. Otherwise, search `plans/` for the most recently modified `MANIFEST.md`. If none exists, report that no multi-epic project is active and suggest `/sdlc-brainstorm`.

## Workflow

Read the `MANIFEST.md` and then verify each epic's actual state on disk. For each epic, check whether `spec.md`, `edge-cases.md`, `index.md`, and task files exist, and count how many task files have all acceptance criteria marked `[x]`. Reconcile the manifest with reality -- if disk state is ahead of what the manifest records (e.g., a plan exists but status says "Spec Ready"), update the manifest to match.

Check the Open Issues section. Count unresolved issues by severity. If any HIGH issues are open, flag them prominently.

Determine what is actionable now by walking the dependency graph: an epic is actionable when all its dependencies are at "Validated" or later and its own status is the earliest incomplete phase. Sort actionable epics by phase priority (Phase A before B before C) and within a phase by critical path position.

Print a concise dashboard showing every epic's status in a table, followed by open issue counts, then a "What's Next" section with the specific skill to run. For example: "Run `/sdlc-plan plans/2026-03-28-budgeting-core-mvp/epics/2026-03-28-mock-data-layer` -- no blockers, highest priority in Phase A." If multiple epics are actionable in parallel, list them all.

## Rules

Always reconcile manifest with disk state before reporting. Never modify spec or plan files -- only update the manifest's status fields. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
