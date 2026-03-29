---
name: sdlc-complete
description: Archive a finished project. Use after all epics are Done to move the project folder to plans/complete/.
---

# Complete: Archive Finished Work

Flow: design -> implement -> **[complete]**

Resolve target from `$ARGUMENTS`, a task file path, or prompt user.

## Workflow

Begin by resolving the target to the project folder containing a `MANIFEST.md`. If a path to an individual epic or task is given, walk up to the project root. Read the manifest and check whether all epics are marked "Complete." If they are, present the source path and target archival path to the user and request explicit confirmation before proceeding. If some epics remain incomplete, list them and ask whether to proceed anyway. Move the entire project folder -- manifest, research, epics, and all supporting files -- to `plans/complete/YYYY-MM-DD-<project-slug>/`. Provide a report of the archival and the new file locations, including a final summary: total epics, total tasks completed, and timeline from manifest creation to completion.

## Rules

Never archive without explicit user confirmation. Warn for incomplete tasks rather than skipping silently. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
