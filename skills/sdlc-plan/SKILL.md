---
name: sdlc-plan
description: Break a spec into a stacked PR implementation plan with branch-per-task and full requirement traceability. Use after /sdlc-brainstorm to produce a plan before implementation.
---

# Plan: Generate Implementation Plan from Specification

Flow: brainstorm -> **[plan]** -> validate -> implement -> complete

Input: `plans/YYYY-MM-DD-<slug>/spec.md`
Output: `plans/YYYY-MM-DD-<slug>/index.md` + task files

If `$ARGUMENTS` is empty, list `plans/` directories and direct to `/sdlc-brainstorm` if none exist.

## Workflow

Begin by reading the project context, including architectural documentation and agent instructions. Read the `MANIFEST.md` from the project root and the upstream epic specs listed as dependencies to understand interfaces this epic will consume.

Perform thorough analysis of the specification to extract all requirements, decisions, scope, and edge cases. Explore the codebase to identify existing patterns and relevant reference files. Decompose the implementation into discrete, reviewable tasks as vertical slices -- each covering a complete path through all affected layers rather than grouping by layer. Every FR and NFR from the spec must be covered, tests included per task, and parallel-safe tasks marked where adjacent work is independent. Present the task breakdown as a numbered list and ask: "Does the granularity feel right -- too coarse, too fine, or should any tasks be merged or split?" Iterate until the user approves. Once finalized, write the index and individual task files.

After writing the plan, update the manifest: set the epic's status to "Planned", record the plan path, and note which downstream epics are now unblocked because all their dependencies have reached at least "Planned."

## Index Format

```
# Implementation Plan: <Spec Title>

Source spec: spec.md
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

Focus exclusively on generating the plan with no implementation code. Ensure every requirement from the spec is covered by at least one task. Use standardized branch naming and verify `plans/` is git-ignored. Once finished, suggest proceeding to validation. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
