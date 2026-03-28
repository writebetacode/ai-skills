---
name: sdlc-complete
description: Archive a finished epic or entire project. Use after all tasks are Done to move plans to plans/complete/.
---

# Complete: Archive Finished Work

Flow: brainstorm -> plan -> validate -> implement -> **[complete]**

Resolve target from `$ARGUMENTS`, a task file path, or prompt user.

## Workflow

Begin by resolving the target. If it points to a single epic's plan directory, verify completion by reading the index file and confirming all tasks are done, warning if any remain incomplete. Update the `MANIFEST.md` to mark the epic as "Complete" and report which downstream epics are now fully unblocked.

If the target points to a project folder containing a `MANIFEST.md`, check whether all epics are marked "Complete." If they are, offer to archive the entire project as a unit. If some remain incomplete, list them and ask whether to proceed anyway.

Present the source path and target archival path to the user and request explicit confirmation before proceeding. For a single epic, move its directory to `plans/complete/YYYY-MM-DD-<slug>/`. For a full project, move the entire project folder -- manifest, research, epics, and all supporting files -- to `plans/complete/YYYY-MM-DD-<project-slug>/`.

Provide a report of the archival and the new file locations. For project archival, include a final summary: total epics, total tasks completed, and timeline from manifest creation to completion.

## Rules

Never archive without explicit user confirmation. Warn for incomplete tasks rather than skipping silently. ASCII only, no AI attribution.

## User Input

$ARGUMENTS
