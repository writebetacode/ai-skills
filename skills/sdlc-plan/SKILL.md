---
name: sdlc-plan
description: Break a spec into a stacked PR implementation plan with branch-per-task and full requirement traceability. Use after /sdlc-brainstorm to produce a plan before implementation.
---

# Plan: Generate Implementation Plan from Specification

Flow: brainstorm -> **[plan]** -> implement -> complete

Input: `plans/YYYY-MM-DD-<slug>/spec.md`
Output: `plans/YYYY-MM-DD-<slug>/plan.md` + task files

If `$ARGUMENTS` is empty, list `plans/` directories and direct to `/sdlc-brainstorm` if none exist.

## Workflow

Begin by reading the full project context. Load the `MANIFEST.md`, `epics.md`, the architecture brief from brainstorm's research output, and every completed `spec.md` across all epics -- not just the target epic. This gives the team a shared understanding of what the entire project is building, how epics relate, and what interfaces are being produced and consumed.

Spin up an agent team with model `inherit` to produce the plan. The team structure scales naturally -- a single-epic project simply has one planner.

The **researcher** loads all prior research output, architecture docs, and codebase context. It explores the codebase to identify existing patterns, relevant reference files, and implementation precedents. It fields factual and codebase questions from other agents and gathers additional findings via web search when needed. Every URL the researcher provides must be verified as reachable. The **architect** reads the full project context -- manifest, all specs, the architecture brief, and any already-completed plans from sibling epics -- then reviews each planner's task breakdown for cross-epic cohesion, dependency alignment, interface consistency, and branch strategy. The architect stays live to answer structural questions and flags issues back to planners for immediate correction. Each **planner** (one per epic being planned) performs thorough analysis of its specification to extract all requirements, decisions, scope, and edge cases. It decomposes the implementation into discrete, reviewable tasks as vertical slices -- each covering a complete path through all affected layers rather than grouping by layer. Every FR and NFR from the spec must be covered, tests included per task, and parallel-safe tasks marked where adjacent work is independent. The planner presents its task breakdown and iterates with the user until approved, then writes the plan and individual task files. The **validator** runs concurrently, checking each completed plan against the source spec, the architecture brief, and other plans for requirement coverage gaps, phantom references, interface mismatches, scope drift, and branch naming consistency. It messages the relevant planner and architect to resolve issues immediately -- only genuinely unresolvable items requiring human decision are recorded as open issues in the manifest.

After writing all plans, update the manifest: set each epic's status to "Planned", record the plan path, and note which downstream epics are now unblocked because all their dependencies have reached at least "Planned." End with: "Plans ready. Run `/sdlc-implement` to begin."

## Plan Format

File: `plan.md`

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

Focus exclusively on generating the plan with no implementation code. Ensure every requirement from the spec is covered by at least one task. Use standardized branch naming and verify `plans/` is git-ignored. Phases within the agent team are strictly sequential: researcher and architect establish context before planners begin, but the validator runs concurrently with planners. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
