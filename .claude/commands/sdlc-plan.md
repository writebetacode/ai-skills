---
name: sdlc-plan
description: Break a spec into a stacked PR implementation plan with branch-per-task and full requirement traceability. Use after /sdlc:brainstorm to produce a plan before implementation.
model: opus
---

# Plan: Generate Implementation Plan from Specification

Flow: brainstorm → **[plan]** → validate → implement → complete

Input: `plans/YYYY-MM-DD-<slug>/spec.md`
Output: `plans/YYYY-MM-DD-<slug>/index.md` + task files

If `$ARGUMENTS` is empty, list `plans/` directories. If none, direct to `/sdlc:brainstorm`. Otherwise resolve as plan directory (look for `spec.md` inside).

## Workflow

1. **Read context**: Read CLAUDE.md/.cursorrules/AGENTS.md and docs/architecture.md if present.
2. **Analyze spec**: Read the spec in full. Extract requirements (FR-1, FR-2, NFR-1, etc.), decisions, scope, architectural context, and reference files.
3. **Explore codebase**: Read reference files and search for additional relevant code. Focus on existing patterns, boundaries, and test conventions.
4. **Decompose into tasks**: Each task = one reviewable PR via vertical slice (complete path through all affected layers — not "all models first, then all handlers"). Branch from main unless the code genuinely depends on a prior task. Every FR/NFR covered. Tests included per task. Mark parallel-safe tasks where adjacent work is independent.
5. **Validate granularity**: Present task breakdown as numbered list (title + one-line summary). Ask: "Does the granularity feel right — too coarse, too fine, or should any tasks be merged or split?" Iterate until approved, then write.
6. **Write files**: Ensure `plans/YYYY-MM-DD-<slug>/` exists and `plans/` is in `.gitignore`. Write index.md and all task files alongside spec.md.

## Index Format

```
# Implementation Plan: <Spec Title>

Source spec: plans/YYYY-MM-DD-<slug>/spec.md
Date: <YYYY-MM-DD>

## Approach
<2-4 sentences on overall strategy.>

## Dependency Graph
main -> feat/<slug>/01-name -> feat/<slug>/02-name
                               [parallel-safe: 02, 03]

## Tasks
| Task | Branch | Base | Spec Requirements | Summary | Status |
|------|--------|------|-------------------|---------|--------|
| 01-<name> | <type>/<slug>/01-<name> | main | FR-1, FR-2 | <one-line> | Todo |
```

## Task File Format

File: `NN-<name>.md`

```
# Task NN: <Title>

Branch: <type>/<spec-slug>/NN-<task-name>
Base: main OR prior task branch

## Spec Requirements
- FR-<N>: <quoted requirement text>
- NFR-<N>: <quoted requirement text>

## Description
<2-4 paragraphs on WHAT and WHY, not HOW.>

## Key Files
- path/to/file -- <expected change>

## Acceptance Criteria
1. <Testable outcome>

## Dependencies
<Prior tasks, or "None (branches from main).">
```

## Rules

- Plans only — no implementation code
- Every spec requirement must be covered
- Branch names use `<type>/<slug>/NN-<name>`
- `plans/` in .gitignore
- ASCII only, no AI attribution

Suggest `/sdlc:validate` when done.

## User Input

$ARGUMENTS
