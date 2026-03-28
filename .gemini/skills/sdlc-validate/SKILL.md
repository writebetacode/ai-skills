---
name: sdlc-validate
description: Verify epic coherence across a project or plan coverage for a single epic. Use after sdlc-brainstorm for epic validation or after sdlc-plan for plan validation.
---

# Validate: Epic Coherence or Plan Coverage

Flow: brainstorm -> plan -> **[validate]** -> implement -> complete

If the user's request is empty, list `plans/` directories and prompt for a target.

## Mode Detection

When the target contains a `MANIFEST.md`, run epic validation across the entire project. When the target is a plan directory with `index.md`, run plan validation for that single epic. When a manifest path is passed alongside a plan directory, run plan validation with cross-epic awareness.

## Epic Validation

Load the manifest, `epics.md`, `build-plan.md`, `review.md`, and every `spec.md` and `edge-cases.md` under `epics/`. Run the following checks, recording each as PASS or FAIL with details: every epic in the manifest has a spec on disk; no two epics overlap in scope or contradict each other's decisions; cross-epic interfaces are consistent (e.g., if Epic 5 consumes `useBudget()` from Epic 4, the field shapes match); the dependency graph in `build-plan.md` matches the `## Dependencies` sections in individual specs; edge case files do not introduce scope that belongs to a different epic; and no spec contains fabricated sources or ambiguous requirements. Present the full report and offer to fix issues in-place. Update the manifest's open issues section with any new findings.

## Plan Validation

Load the source spec, `edge-cases.md` (if present), `index.md`, and all task files sorted by number. If the spec is missing, record a critical failure but continue. Run these checks:

Requirement Coverage: every FR-N/NFR-N from both `spec.md` and `edge-cases.md` is referenced by at least one task (flag orphans); every task reference points to a real requirement (flag phantoms). Task Ordering: sequential numbering with no gaps or duplicates; each Base points to main or a valid prior branch; branch names follow convention; filenames match branches. Structural Completeness: each task file contains all required sections, present and non-empty. Index Consistency: tasks table matches files on disk; branch names agree; dependency graph reflects actual base relationships. Spec Drift: quoted requirement text matches the spec exactly (not paraphrased); scope covers all in-scope items with no out-of-scope additions. Also check that interface assumptions in this plan match what upstream specs define in the manifest.

Present the full PASS/FAIL report. If issues are found, offer to fix in-place without modifying the spec. Update the manifest status to "Validated" on success.

## Rules

Always fix in-place, never regenerate from scratch. Never modify the spec. Show the full report even if all checks pass. ASCII only, no AI attribution. After validation, suggest clearing context and beginning the implementation phase.
