---
name: sdlc-revise
description: Propagate mid-implementation changes back through specs, plans, and manifest. Use when requirements shift during implementation.
---

# Revise: Propagate Changes Through the SDLC Chain

If the user's request is empty, ask what changed and which epic is affected.

## Workflow

Start by identifying the scope of the change. Read the user's description and determine which epic is affected. Load that epic's `spec.md`, `edge-cases.md` (if present), `index.md`, and all task files. If a `MANIFEST.md` exists, load it along with any downstream epic specs that list this epic as a dependency.

Present the proposed changes before making them. Show exactly which files will be modified, what text will change, and which downstream epics may be affected. Ask the user to confirm before writing anything.

On confirmation, update the affected spec -- modifying requirements, decisions, or scope as needed. If the change affects edge cases, update `edge-cases.md` as well. Then update the implementation plan: revise acceptance criteria in affected task files, adjust the index if task scope or ordering changes, and re-map spec requirement references if FR/NFR numbers shifted.

Check the manifest for downstream impact. If the change alters an interface that other epics depend on (e.g., a hook signature, a data shape, an API contract), flag each affected downstream epic and describe the inconsistency. Offer to update those specs as well, or note them as open issues in the manifest.

Run validation on the affected epic to ensure the revised plan still covers all requirements. Present a summary: what changed, which files were updated, and any downstream issues that need attention.

## Updating Existing Skills

When the task is to update an existing skill rather than create a new one, read the current file first and diff the proposed changes against it. Explicitly list any existing functionality that would be removed and ask the user to confirm each removal before writing. Never drop behavioral details silently — if a step, rule, or constraint is present in the current skill, it must either be preserved in the updated version or explicitly approved for removal by the user.

## Rules

Never modify files without showing the proposed changes and receiving user confirmation. Preserve existing work -- revise in-place rather than regenerating. When downstream epics are affected, flag but do not auto-fix without confirmation. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.
