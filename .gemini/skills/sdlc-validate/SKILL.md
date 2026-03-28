---
name: sdlc-validate
description: Verify an implementation plan has full requirement coverage, correct structure, and no spec drift. Use after sdlc-plan and before sdlc-implement to catch issues early.
---

# Validate: Check Implementation Plan Against Specification

Flow: brainstorm → plan → **[validate]** → implement → complete

Input: `plans/YYYY-MM-DD-<slug>/`
Validates against: `plans/YYYY-MM-DD-<slug>/spec.md`

If the user's request is empty, list `plans/` directories and direct to `sdlc-plan` if none exist.

## Workflow

Resolve the target plan directory, then load the source specification, index.md, and all task files (`[0-9][0-9]-*.md` sorted by number) in a single turn. If the spec is missing, record it as a critical failure but continue checking the remaining files. Run the following checks and record each as PASS or FAIL with details:

- **Requirement Coverage**: every FR-N/NFR-N is referenced by at least one task (flag orphans); every task reference points to a real spec requirement (flag phantoms).
- **Task Ordering**: sequential numbering with no gaps or duplicates; each Base points to main or a valid prior task branch; branch names follow `<type>/<spec-slug>/NN-<task-name>`; filenames match branch names.
- **Structural Completeness**: each task file contains Spec Requirements, Description, Key Files, Acceptance Criteria, and Dependencies — all present and non-empty.
- **Index Consistency**: tasks table matches files on disk; branch names agree between index and task files; dependency graph reflects actual base relationships; `spec.md` exists alongside `index.md`.
- **Spec Drift**: quoted requirement text matches the spec exactly (not paraphrased); collective scope covers all in-scope items with no out-of-scope additions; no contradictions with spec decisions.

Present the full PASS/FAIL report grouped by category — always show it, even if all checks pass. If issues are found, offer to fix them in-place without modifying the spec.

## Rules

Always perform fixes in-place and never regenerate plan files from scratch. Maintain the integrity of the original specification by never modifying its content. Ensure the full validation report is shown to the user even if all checks pass. Adhere to ASCII-only formatting and exclude any AI attribution from all outputs. Once the plan is validated, tell the user to clear the context before beginning the implementation phase.
