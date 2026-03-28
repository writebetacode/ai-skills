---
name: sdlc-complete
description: Archive a finished implementation plan. Use after all tasks are Done to move the plan and spec to plans/complete/.
---

# Complete: Archive a Finished Implementation Plan

Flow: brainstorm → plan → validate → implement → **[complete]**

Resolve plan directory from user input, a task file path, or prompt user.

## Workflow

Begin by resolving the target plan directory from the provided input or by prompting the user. Verify the completion of the plan by reading the index file and confirming that all tasks are marked as done, issuing a warning if any remain incomplete. Present the plan directory and the target archival path to the user and request explicit confirmation before proceeding. Once confirmed, move the entire directory, including the specification, index, and all task files, to the completed plans location. Finally, provide a report of the archival process and the new location of the plan files.

## Rules

Never perform any archival operations without explicit user confirmation and always issue a warning for any incomplete tasks rather than skipping them silently. Maintain ASCII-only formatting and ensure that no AI attribution is included in the final outputs.
