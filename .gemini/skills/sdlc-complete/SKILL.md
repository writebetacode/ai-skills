---
name: sdlc-complete
description: Archive a finished implementation plan. Use after all tasks are Done to move the plan and spec to plans/complete/.
---

# Complete: Archive a Finished Implementation Plan

Flow: brainstorm → plan → validate → implement → **[complete]**

Resolve plan directory from the user's request, a task file path, or prompt user.

## Workflow

1. **Verify**: Read `index.md` — confirm all tasks show Status: Done. Warn for any not Done and ask `Proceed anyway? (yes/no)`.
2. **Confirm**: Show the plan directory and target path `plans/complete/YYYY-MM-DD-<slug>/`. Ask `Archive? (yes/no)`.
3. **Archive**: Move plan directory and its source spec to `plans/complete/YYYY-MM-DD-<slug>/`. Remove any empty implementation directory.
4. **Report**: List what was archived and where.

## Rules

- Never archive without user confirmation
- Warn, never silently skip, incomplete tasks
- ASCII only, no AI attribution
