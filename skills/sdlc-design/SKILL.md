---
name: sdlc-design
description: Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning and an architect-led agent team. Use when starting a new feature that needs a written plan before implementation, or when a mid-flight revision forces the plan back onto the table.
model: opus
---

# Design: From Idea to Implementation Plan

Flow: **[design]** -> implement -> complete

## Agent Team

Spec/plan authoring and all intake MUST happen through a team via TeamCreate named `sdlc-design-<project-slug>`. Create the team at the very start, before any questioning. Spawn one permanent agent via `Agent` with `team_name` matching and `name` set to `sdlc-architect` (opus). The architect's AGENT.md carries its workflow and identity — do not re-specify here. The architect owns intake, research, all artifact authoring (specs, plans, task files, MANIFEST), and signoff; it stays live throughout design. Never produce specs, plans, or task files directly in the main conversation, and never drive questioning from the main conversation.

## Orchestrator Role

The main thread is a pure router. It creates the team, spawns the agent, forwards every user reply to `sdlc-architect` via `SendMessage`, and relays the architect's next question back verbatim. No own questions, no pre-review, no commentary, no deciding when intake is complete. If `$ARGUMENTS` is empty, forward that fact to the architect on spawn so it opens with a prompt for what to build.

## Questioning Rules

Architect asks exactly one question per turn. No compounds ("A and also B?"), no sub-questions smuggled in as examples ("What auth? JWT or sessions?"), no lettered/numbered/bulleted sub-parts within a turn — each sub-part is its own question on its own turn. When the codebase suggests an answer, propose it as a one-word-confirm default ("Looks like you're using JWTs — confirm?") instead of open-ended. After every answer, the architect pauses and decides: accept, drill, or move on. The user may interrupt to drill any topic; honor it fully before resuming. Respond completely to any question the user asks back before continuing. The main thread enforces discipline by relaying untouched — no batching, rephrasing, or supplementing.

## Workflow

Open by creating the team and spawning `sdlc-architect`. On spawn, the architect reads `docs/adrs/**/*.md` so prior decisions bind new work, then pulls existing skills, patterns, and files the prompt touches. Runs the questioning loop under the rules above, doing codebase lookups inline and resolving every package/library/framework/SDK/CLI version via `context7` with source/version/retrieval-date citations. If scope decomposes into independent work streams, the architect proposes: "This looks like a multi-epic project — I'd like to decompose it into N epics." Once concrete, the architect authors `spec.md` per epic, decomposes each spec into vertical-slice tasks (~500 LOC per PR target), writes `plan.md`, emits `tasks/NN-<name>.md` files in run order, runs the gates below, and writes `MANIFEST.md`.

## Stack-Linearity Gate

Before plan signoff, the architect walks the task graph and rejects any task whose `Base` names two different prior branches. Every task has exactly one parent — `main` or one prior task branch. If a task needs state from two prior branches, flatten them (merge priors into one task, or split the current task) and redo the plan. Absolute gate; no exceptions.

## Concurrency Model

Within an epic, tasks are strictly linear: NN order is run order, every task stacks on one parent, the implement skill walks them in sequence. Deliberate choice — keeps the stack reviewable and the rebase story simple. Across epics, parallelism is allowed: when two epics in `epics.md` declare disjoint dependency sets, they may run concurrently in separate working trees, since each epic's first task branches from `main`. Build Order in `epics.md` is the recommended single-operator sequence; the dependency graph is the source of truth for fan-out. The implement skill operates on one epic at a time; concurrent epics means two `/sdlc-implement` sessions in two checkouts.

## Ordering Gate

Every task's NN-prefix matches its position in run order: 01 first, 02 second, no gaps, no reorderings. A task file `04-...` that runs before `03-...` is rejected as a seam bug and renumbered before signoff. Same rule for epic folders; single-epic projects use `01-`. Mismatches are renumbered before signoff.

## Mid-Flight Revision

When `$ARGUMENTS` names an existing project and the user requests a revision (architecture shift, scope change, reshape), enter revision mode. Pause in-flight implementation — do not touch partial work; tell the user to stash or leave the tree alone. Re-spawn the design team (same TeamCreate name is fine) and route all revision intake through it under the orchestrator-as-router rule. The architect reads the manifest, completed task files, and in-progress work, then decides per remaining task: **keep** (unchanged), **revise** (updated spec — mark `[revised: vN]` in MANIFEST and overwrite the task file), or **void** (no longer needed — mark `[voided: <reason>]` in MANIFEST, leave the file in place for history). Append any new tasks with fresh NN-prefixes continuing the sequence. Update `adr.md` with the triggering decision. Confirm the updated plan with the user before returning them to `/sdlc-implement`.

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

`prd.md` is optional — write it only when the project has user-facing product requirements worth separating from the technical spec (the WHAT, distinct from the HOW). When `prd.md` exists, every epic's `spec.md` MUST cite it under `## Dependencies` ("PRD: prd.md") and trace each FR to a specific PRD section by quoted phrase or heading; an unreferenced PRD is a stranded artifact and the architect either wires it in or deletes it. `adr.md` is required as a running log of every project-level decision, one heading per decision with context, decision, consequences. When a decision is strong enough to outlive the project (naming conventions, cross-cutting framework choice, data contract family), promote it to `docs/adrs/<YYYYMMDD>-<slug>.md` in the host repo and note the promotion in `adr.md`. Every design session begins with the architect reading all existing `docs/adrs/**/*.md`.

## Team Teardown

Once the architect signs off and `MANIFEST.md` is written, shut down the team. Send `SendMessage` with `{type: "shutdown_request", reason: "Design complete."}`, wait for `shutdown_approved`, then call `TeamDelete`. Do not skip teardown — leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-design, leave the team running to preserve context; teardown happens only at signoff or when a mid-flight revision returns control to `/sdlc-implement`.

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

Optional `Depth: ultrathink` line directly below `Base:` when the architect flags a task as needing maximum-depth reasoning — reserved for genuinely gnarly work (novel territory, subtle correctness, concurrency, high spec-drift risk). `/sdlc-implement` reads this and prepends `ultrathink` to tester and coder handoffs. Omit on routine work.

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

## Rules

NEVER produce specs, plans, or task files directly in the main conversation; NEVER drive intake from the main conversation — all artifacts and questions come through `sdlc-architect` via TeamCreate. Architect owns intake, research, authoring, signoff inline. Main thread is a pure router: relay messages between user and architect without injecting questions or commentary. One question per turn, no compounds, no sub-questions as examples, no lettered/numbered/bulleted sub-parts. Honor user-initiated drill-downs fully before resuming. Every task has exactly one parent branch — stack-linearity is absolute. NN-prefix must match run order for epics and tasks. Always read `docs/adrs/**/*.md` at session start. Never fabricate sources or URLs. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
