---
name: sdlc-validate
description: Verify an implementation plan has full requirement coverage, correct structure, and no spec drift. Use after /sdlc:plan and before /sdlc:implement to catch issues early.
model: opus
---

# Validate: Check Implementation Plan Against Specification

Flow: brainstorm → plan → **[validate]** → implement → complete

Input: `plans/implementations/<slug>/`
Validates against: `plans/specs/YYYY-MM-DD-<slug>.md`

If `$ARGUMENTS` is empty, list `plans/implementations/`. If none, direct to `/sdlc:plan`. Otherwise resolve as plan directory (prepend `plans/implementations/` if needed).

## Workflow

1. **Intake**: Resolve the target plan directory from `$ARGUMENTS` or list options.
2. **Batch read**: Load the source spec, index.md, and all task files (`[0-9][0-9]-*.md` sorted by number) in a single turn. If spec missing, record as critical but continue.
3. **Run checks**: Record each as PASS or FAIL with details.

   **Requirement Coverage**
   - Every FR-N/NFR-N referenced by at least one task (flag orphans)
   - Every task reference points to a real spec requirement (flag phantoms)

   **Task Ordering**
   - Sequential numbering, no gaps/duplicates
   - Each Base points to main or a valid prior task branch
   - Branch naming: `<type>/<spec-slug>/NN-<task-name>`
   - Filenames match branch names

   **Structural Completeness (per task)**
   - Spec Requirements, Description, Key Files, Acceptance Criteria, Dependencies — all present and non-empty

   **Index Consistency**
   - Tasks table matches files on disk; branch names agree between index and task files
   - Dependency graph reflects actual base relationships
   - Source spec path exists

   **Spec Drift**
   - Quoted requirement text matches spec exactly (not paraphrased or outdated)
   - Collective scope covers all in-scope items and introduces no out-of-scope work
   - No contradictions with spec decisions

4. **Report**: Output PASS/FAIL report grouped by category — always show, even if all pass.
5. **Fix if requested**: If issues found, offer to fix in-place (never regenerate from scratch). Confirm before writing. Never modify the spec.

## Rules

- Fix in-place only — never regenerate from scratch
- Never modify the spec — only plan files
- Always show the full report, even if all checks pass
- ASCII only, no AI attribution

Suggest `/sdlc:implement` when valid.

## User Input

$ARGUMENTS
