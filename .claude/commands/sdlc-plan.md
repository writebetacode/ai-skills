---
name: sdlc-plan
description: Break a spec into a stacked PR implementation plan with branch-per-task and full requirement traceability. Use after /sdlc:brainstorm to produce a plan before implementation.
---

# Plan: Generate Implementation Plan from Specification

Flow: brainstorm → **[plan]** → validate → implement → complete

Input: `plans/YYYY-MM-DD-<slug>/spec.md`
Output: `plans/YYYY-MM-DD-<slug>/index.md` + task files

If `$ARGUMENTS` is empty, list `plans/` directories and direct to `/sdlc:brainstorm` if none exist.

## Workflow

Begin by reading the project context, including architectural documentation and agent instructions. Perform a thorough analysis of the specification to extract all requirements, decisions, and scope. Explore the codebase to identify existing patterns and relevant reference files. Decompose the implementation into discrete, reviewable tasks as vertical slices — each covering a complete path through all affected layers rather than grouping by layer (not "all models first, then all handlers"). Every FR and NFR must be covered, tests included per task, and parallel-safe tasks marked where adjacent work is independent. Present the task breakdown as a numbered list and ask: "Does the granularity feel right — too coarse, too fine, or should any tasks be merged or split?" Iterate until the user approves. Once finalized, ensure the directory exists and write the index and individual task files while confirming that the `plans/` directory is properly ignored by git.

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

Focus exclusively on generating the plan and do not include any implementation code. Ensure every requirement from the specification is covered by at least one task. Use the standardized branch naming convention and verify that the `plans/` directory is in the `.gitignore`. Maintain ASCII-only formatting and exclude any AI attribution from the final outputs. Once finished, suggest proceeding to the validation phase.

## User Input

$ARGUMENTS
