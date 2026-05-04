---
name: sdlc-design
description: Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning and an architect-led agent team. Use when starting a new feature that needs a written plan before implementation, or when a mid-flight revision forces the plan back onto the table.
model: opus
---

# Design: From Idea to Implementation Plan

Flow: **[design]** -> implement -> complete

## Agent Team

Spec and plan authoring, and all intake questioning, MUST happen through a team created via TeamCreate named `sdlc-design-<project-slug>`. The team spins up at the very start of the skill, before any questioning. Spawn one permanent agent via `Agent` with `team_name` matching the TeamCreate name and `name` set to `sdlc-architect` (opus). The architect's AGENT.md carries its workflow and identity -- do not re-specify here. The architect owns intake, research, all artifact authoring (specs, plans, task files, MANIFEST), and signoff; it stays live throughout design. Never produce specs, plans, or task files directly in the main conversation, and never drive questioning from the main conversation.

## Orchestrator Role

The main thread is a pure router. It creates the team, spawns the agents, forwards every user reply to `sdlc-architect` via `SendMessage`, and relays its next question back to the user verbatim. It does not ask its own questions, does not pre-review answers, does not inject commentary, and does not decide when intake is complete -- the architect owns all of that. If `$ARGUMENTS` is empty, forward that fact to the architect on spawn so it can open with a prompt for what to build.

## Questioning Rules

The architect owns intake and asks exactly one question per turn. Never compound two questions into one ("A and also B?"), never smuggle sub-questions in as examples ("What auth? JWT or sessions?"), and never split one turn into numbered or lettered sub-parts (`a/b/c`, `i/ii/iii`, bullets) -- each sub-part is its own question and must go on its own turn. When the codebase suggests a likely answer, propose it as a default the user confirms in one word ("Looks like you're using JWTs -- confirm?") instead of open-ended. After every user answer, the architect pauses and decides whether to accept, drill deeper, or move on. The user may interrupt at any time to drill into any topic; honor it fully before resuming the line. Respond completely to any question the user asks back before continuing. The main thread enforces this discipline by relaying messages untouched -- it does not batch, rephrase, or supplement.

## Workflow

The skill opens by creating the team and spawning `sdlc-architect`. On spawn, the architect reads `docs/adrs/**/*.md` in the host repo so prior architectural decisions bind new work, and pulls any existing skills, patterns, and files the prompt touches. The architect then runs the questioning loop under the rules above, doing codebase lookups inline to inform defaults and resolving every package, library, framework, SDK, and CLI version via `context7` with citations stamped by source, version, and retrieval date. The architect monitors whether scope decomposes into independent work streams; if so, it proposes: "This looks like a multi-epic project -- I'd like to decompose it into N epics." Once all aspects are concrete, the architect authors `spec.md` per epic, decomposes each spec into vertical-slice tasks (~500 LOC per PR target), writes `plan.md`, emits `tasks/NN-<name>.md` files in run order, runs the stack-linearity and NN-ordering gates below, and writes `MANIFEST.md` from the template below.

## Stack-Linearity Gate

Before plan signoff, the architect walks the task graph and rejects any task whose `Base` field names two different prior branches. Every task has exactly one parent -- `main` or one prior task branch. If a task needs state from two prior branches, flatten them (merge the priors into one task, or split the current task) and redo the plan. This is an absolute gate; no exceptions.

## Concurrency Model

Within an epic, tasks are strictly linear: NN order is run order, every task stacks on exactly one parent, and the implement skill walks them in sequence. This is a deliberate design choice, not an oversight -- it keeps the stack reviewable and the rebase story simple. Across epics, parallelism is allowed: when two epics in `epics.md` declare disjoint dependency sets, they may be implemented concurrently in separate working trees or on separate days, since each epic's first task branches from `main`. The Build Order in `epics.md` records a recommended sequence for a single operator; the dependency graph is the source of truth for what can fan out. The implement skill operates on one epic at a time; running two concurrent epics means two `/sdlc-implement` sessions in two checkouts.

## Ordering Gate

The architect confirms every task's NN-prefix matches its position in the run order: 01 runs first, 02 second, no gaps, no reorderings. A task file named `04-...` that runs before `03-...` is rejected as a seam bug and renumbered before signoff. The same rule applies to epic folders: every epic's NN-prefix must match its position in the Build Order, and single-epic projects use `01-`. Mismatches are renumbered before signoff.

## Mid-Flight Revision

When `$ARGUMENTS` names an existing project and the user requests a revision (architecture shift, scope change, reshape), enter revision mode. Pause in-flight implementation -- do not touch partial work; tell the user to stash or leave the tree alone. Re-spawn the design team (same TeamCreate name is fine) with the architect and route all revision intake through it using the same orchestrator-as-router rule. The architect reads the manifest, completed task files, and in-progress work, then decides per remaining task: **keep** (unchanged), **revise** (needs updated spec -- mark `[revised: vN]` in the manifest and overwrite the task file), or **void** (no longer needed -- mark `[voided: <reason>]` in the manifest, leave the file in place for history). Append any new tasks with fresh NN-prefixes continuing the existing sequence. Update `adr.md` with the decision that triggered the revision. Ask the user to confirm the updated plan before returning them to `/sdlc-implement`.

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

Neither project nor epic slug carries a date prefix; the date is appended only on archive.

## PRD and ADR Handling

`prd.md` is optional -- write it only when the project has user-facing product requirements worth separating from the technical spec (the WHAT, distinct from the HOW). When `prd.md` exists, every epic's `spec.md` MUST cite it under `## Dependencies` ("PRD: prd.md") and trace each Functional Requirement to a specific PRD section by quoted phrase or section heading; an unreferenced PRD is a stranded artifact and the architect either wires it in or deletes it. `adr.md` is required as a running log of every project-level architecture decision, one heading per decision with context, decision, and consequences. When a decision is strong enough to outlive the project (naming conventions, cross-cutting framework choice, data contract family), promote it to the host repo as `docs/adrs/<YYYYMMDD>-<slug>.md` and note the promotion in `adr.md`. Every design session begins with the architect reading all existing `docs/adrs/**/*.md` so prior decisions bind the new work.

## Team Teardown

Once the architect has signed off the final plan and `MANIFEST.md` is written, shut down the team. Send `SendMessage` to the architect with `{type: "shutdown_request", reason: "Design complete."}`, wait for the `shutdown_approved` response, then call `TeamDelete` to remove the team and task directories. Do not skip teardown -- leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-design (e.g., user stops for the day), leave the team running to preserve context; teardown happens only when the plan is signed off or when a mid-flight revision session finishes and returns control to `/sdlc-implement`.

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

The task file supports an optional `Depth: ultrathink` line directly below `Base:` when the architect flags a task as needing maximum-depth reasoning during implementation — reserved for genuinely gnarly work (novel territory, subtle correctness, concurrency, high spec-drift risk). `/sdlc-implement` reads this field and prepends `ultrathink` to the tester and coder handoffs when set. Omit the line on routine work.

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

NEVER produce specs, plans, or task files directly in the main conversation, and NEVER drive intake questioning from the main conversation -- all artifacts and questions MUST come through the `sdlc-architect` agent via TeamCreate. The architect owns intake, research, authoring, and signoff inline. The main thread is a pure router: it relays messages between user and architect without injecting its own questions or commentary. Ask only one question at a time with no compounds, no sub-questions as examples, and no lettered/numbered/bulleted sub-parts. Honor user-initiated drill-downs fully before resuming the architect's line. Every task has exactly one parent branch -- stack-linearity is absolute. NN-prefix must match run order for both epics and tasks. Always read `docs/adrs/**/*.md` at session start. Never fabricate sources or URLs. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
