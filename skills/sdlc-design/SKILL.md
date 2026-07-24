---
name: sdlc-design
description: Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning and an architect-led agent team. Use when starting a new feature that needs a written plan before implementation, or when a mid-flight revision forces the plan back onto the table.
model: opus
---

# Design

Flow: **[design]** -> implement -> complete

## Agent Team

Spec/plan authoring and all intake MUST happen through a team via TeamCreate named `sdlc-design-<project-slug>`, created at the very start before any questioning. Spawn one permanent agent via `Agent` with matching `team_name` and `name` set to `sdlc-architect` (opus); its AGENT.md carries the workflow and identity — do not re-specify here. The architect stays live throughout design and owns intake, research, signoff, and every artifact: it proposes a multi-epic split for the user to confirm when scope decomposes into independent streams, then authors `spec.md`, `plan.md`, `tasks/NN-<name>.md` (in run order), runs the gates, and writes `MANIFEST.md`.

## Orchestrator Role

The main thread is a pure router: forward every user reply to `sdlc-architect` via `SendMessage` and relay the architect's next question back verbatim — never batching, rephrasing, or supplementing; no own questions, pre-review, commentary, or deciding when intake is complete. Question discipline is the architect's — its AGENT.md "Intake loop" is authoritative. If `$ARGUMENTS` is empty, tell the architect on spawn so it opens by asking what to build.

## Gates

The architect runs all six signoff gates per its AGENT.md "Gates before signoff" — they are absolute. Two consequences the orchestrator must surface: every task has exactly one parent (`main` or one prior branch; a `Base` naming two priors is flattened and the plan redone), and every NN-prefix matches run order for tasks and epic folders (mismatches renumbered before signoff, single-epic projects use `01-`).

## Concurrency Model

Within an epic, tasks are strictly linear: NN order is run order, every task stacks on one parent, the implement skill walks them in sequence. Across epics, parallelism is allowed: two epics in `epics.md` with disjoint dependency sets run concurrently via two `/sdlc-implement` sessions in separate checkouts, since each epic's first task branches from `main`. Build Order is the recommended single-operator sequence; the dependency graph is the source of truth for fan-out.

## Mid-Flight Revision

When `$ARGUMENTS` names an existing project and the user requests a revision (architecture shift, scope change, reshape), enter revision mode. Never touch in-flight partial work — tell the user to stash or leave the tree alone. Re-spawn the design team (same TeamCreate name is fine) and route all revision intake through it under the orchestrator-as-router rule. The architect reads the manifest, completed task files, and in-progress work, then decides per remaining task: **keep** (unchanged), **revise** (updated spec — mark `[revised: vN]` in MANIFEST and overwrite the task file), or **void** (no longer needed — mark `[voided: <reason>]` in MANIFEST, leave the file in place for history). Append any new tasks with fresh NN-prefixes continuing the sequence. Update `adr.md` with the triggering decision. Confirm the updated plan with the user before returning them to `/sdlc-implement`.

## Project Structure

```
plans/<project-slug>/
  MANIFEST.md                 # central control
  prd.md                      # optional -- WHAT users need, not HOW
  adr.md                      # running log of project-level architecture decisions
  epics.md                    # epic list + dependency graph + build order (multi-epic only)
  research/<topic>.md         # architect's citation notes
  epics/NN-<epic-slug>/        # NN-prefix MUST match Build Order
    spec.md                   # technical specification
    plan.md                   # implementation plan
    tasks/
      01-<task-name>.md       # NN-prefix MUST match run order
      02-<task-name>.md
```

Neither project nor epic slug carries a date prefix; date appends only on archive.

## PRD and ADR Handling

`prd.md` is optional — write it only for user-facing product requirements worth separating from the technical spec (the WHAT, not the HOW). When it exists, every epic's `spec.md` MUST cite it under `## Dependencies` ("PRD: prd.md") and trace each FR to a PRD section by quoted phrase or heading; an unreferenced PRD is wired in or deleted. `adr.md` is a required running log, one heading per project-level decision with context, decision, consequences. A decision strong enough to outlive the project (naming conventions, cross-cutting framework choice, data contract family) promotes to `docs/adrs/<YYYYMMDD>-<slug>.md` in the host repo, noted back in `adr.md`. Every session starts with the architect reading all existing `docs/adrs/**/*.md`.

## Team Teardown

After signoff and `MANIFEST.md` write, shut down: `SendMessage {type: "shutdown_request", reason: "Design complete."}`, await `shutdown_approved`, then `TeamDelete`. Never skip it. If the session pauses mid-design, leave the team running; teardown happens only at signoff or when a mid-flight revision hands control to `/sdlc-implement`.

## Completion

End with: "Design complete. Run `/sdlc-implement` to begin."

## Spec Format

File: `epics/NN-<epic-slug>/spec.md`

```
# <Title>

Date: <YYYY-MM-DD>
Prompt: "<original prompt>"

## Dependencies
<Epic prerequisites by title, or "None.">

## Problem Statement
<2-4 sentences. No prior context assumed.>

## Scope
### In Scope / ### Out of Scope

## Decisions
<Numbered. **<Topic>**: <Decision>. <Rationale>.>

## Requirements
### Functional Requirements / ### Non-Functional Requirements

## Edge Cases
## Architectural Context
## Terminology
<Table: Term | Definition | Aliases to avoid.>
## Reference Files
## Open Questions
```

## Plan Format

File: `epics/NN-<epic-slug>/plan.md`

```
# Implementation Plan: <Spec Title>

Source spec: spec.md
Date: <YYYY-MM-DD>

## Approach
<2-4 sentences on overall strategy.>

## Dependency Graph
main -> feat/<slug>/01-name -> feat/<slug>/02-name

## Tasks
| Task | Branch | Base | Spec Requirements | Summary | Status |
|------|--------|------|-------------------|---------|--------|
| 01-<name> | <type>/<slug>/01-<name> | main | FR-1, FR-2 | <one-line> | Todo |
```

Task Status values: `Todo`, `In Progress`, `Done` (no counts -- counts apply only to epic Status in the manifest).

## Task File Format

File: `epics/NN-<epic-slug>/tasks/NN-<name>.md`

```
# Task NN: <Title>

Branch: <type>/<spec-slug>/NN-<task-name>
Base: main OR exactly one prior task branch

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
<Prior task, or "None (branches from main).">
```

## Manifest Format

File: `MANIFEST.md`

```
# Project Manifest: <Project Name>

Created: YYYY-MM-DD  |  Last updated: YYYY-MM-DD

## Status Dashboard
| # | Epic | Phase | Status | Spec | Plan | Blockers |

### Status Values
Spec Ready -> Planned -> In Progress (N/M) -> Complete

## Build Order
## Open Issues
| # | Severity | Issue | Status | Resolution |
## Actionable Now
```

<!-- no response-style block by design: router relays architect questions verbatim -->
## Rules

NEVER produce specs, plans, or task files in the main conversation, and NEVER drive intake there — all artifacts and questions come through `sdlc-architect` via TeamCreate. Research and gate rules are the architect's. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
