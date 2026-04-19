---
name: sdlc-design
description: Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning and an architect-led agent team. Use when starting a new feature that needs a written plan before implementation, or when a mid-flight revision forces the plan back onto the table.
---

# Design: From Idea to Implementation Plan

Flow: **[design]** -> implement -> complete

If `$ARGUMENTS` is empty, ask what to build. Do not proceed without a substantive prompt.

## Questioning Rules

Ask exactly one question per turn. Never compound two questions into one ("A and also B?"), and never smuggle sub-questions in as examples ("What auth? JWT or sessions?"). When the codebase suggests a likely answer, propose it as a default the user confirms in one word ("Looks like you're using JWTs — confirm?") instead of open-ended. After every user answer, pause and decide whether to accept, drill deeper, or move on. The user may interrupt at any time to drill into any topic; honor it fully before resuming your line. Respond completely to any question the user asks back before continuing.

## Agent Team

Spec and plan authoring MUST happen through a team created via TeamCreate named `sdlc-design-<project-slug>`. Spawn three permanent agents via `Agent` with `team_name` matching the TeamCreate name and `name` matching each identifier: `architect` (opus), `researcher` (sonnet), `document-writer` (sonnet). Each agent's AGENT.md carries its workflow and identity — do not re-specify here. The architect stays live throughout design and signs off every artifact. Never produce specs, plans, or task files directly in the main conversation.

## Workflow

Read relevant context: `docs/adrs/**/*.md` in the host repo (prior architectural decisions bind new work), existing skills and patterns, and files the prompt touches. Run the questioning loop under the rules above until scope and decisions are concrete. Route factual lookups through the researcher as they arise — every package, library, framework, SDK, and CLI version must be resolved via `context7` and cited. Monitor whether scope decomposes into independent work streams; if so, propose: "This looks like a multi-epic project — I'd like to decompose it into N epics." Continue until all aspects are concrete, then hand off to the team.

The document-writer produces one `spec.md` per epic, routing factual questions to the researcher and structural questions to the architect. The architect signs off each spec before planning begins. The document-writer then transitions into planner — decomposes each spec into vertical-slice tasks (~500 LOC per PR target), writes `plan.md`, and emits `tasks/NN-<name>.md` files in run order. The architect reviews the full plan end-to-end, runs the stack-linearity gate and NN-ordering gate below, and signs off. The document-writer generates `MANIFEST.md` from the template below.

## Stack-Linearity Gate

Before plan signoff, the architect walks the task graph and rejects any task whose `Base` field names two different prior branches. Every task has exactly one parent — `main` or one prior task branch. If a task needs state from two prior branches, flatten them (merge the priors into one task, or split the current task) and redo the plan. This is an absolute gate; no exceptions.

## Task Ordering Gate

The architect confirms every task's NN-prefix matches its position in the run order: 01 runs first, 02 second, no gaps, no reorderings. A task file named `04-...` that runs before `03-...` is rejected as a seam bug and renumbered before signoff.

## Mid-Flight Revision

When `$ARGUMENTS` names an existing project and the user requests a revision (architecture shift, scope change, reshape), enter revision mode. Pause in-flight implementation — do not touch partial work; tell the user to stash or leave the tree alone. Re-spawn the design team (same TeamCreate name is fine). The architect reads the manifest, completed task files, and in-progress work, then decides per remaining task: **keep** (unchanged), **revise** (needs updated spec — mark `[revised: vN]` in the manifest and overwrite the task file), or **void** (no longer needed — mark `[voided: <reason>]` in the manifest, leave the file in place for history). Append any new tasks with fresh NN-prefixes continuing the existing sequence. Update `adr.md` with the decision that triggered the revision. Ask the user to confirm the updated plan before returning them to `/sdlc-implement`.

## Project Structure

```
plans/<project-slug>/
  MANIFEST.md                 # central control
  prd.md                      # optional — WHAT users need, not HOW
  adr.md                      # running log of project-level architecture decisions
  epics.md                    # epic list + dependency graph + build order (multi-epic only)
  research/<topic>.md         # researcher citations
  epics/<epic-slug>/
    spec.md                   # technical specification
    plan.md                   # implementation plan
    tasks/
      01-<task-name>.md       # NN-prefix MUST match run order
      02-<task-name>.md
```

Neither project nor epic slug carries a date prefix; the date is appended only on archive.

## PRD and ADR Handling

`prd.md` is optional — write it only when the project has user-facing product requirements worth separating from the technical spec (the WHAT, distinct from the HOW). `adr.md` is required as a running log of every project-level architecture decision, one heading per decision with context, decision, and consequences. When a decision is strong enough to outlive the project (naming conventions, cross-cutting framework choice, data contract family), promote it to the host repo as `docs/adrs/<YYYYMMDD>-<slug>.md` and note the promotion in `adr.md`. Every design session begins by reading all existing `docs/adrs/**/*.md` so prior decisions bind the new work.

## Team Teardown

Once the architect has signed off the final plan and `MANIFEST.md` is written, shut down the team. Send `SendMessage` to each agent with `{type: "shutdown_request", reason: "Design complete."}`, wait for every `shutdown_approved` response, then call `TeamDelete` to remove the team and task directories. Do not skip teardown — leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-design (e.g., user stops for the day), leave the team running to preserve context; teardown happens only when the plan is signed off or when a mid-flight revision session finishes and returns control to `/sdlc-implement`.

## Completion

End with: "Design complete. Run `/sdlc-implement` to begin."

## Spec Format

File: `epics/<epic-slug>/spec.md`

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

File: `epics/<epic-slug>/plan.md`

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

File: `epics/<epic-slug>/tasks/NN-<name>.md`

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

## Rules

NEVER produce specs, plans, or task files directly in the main conversation — all artifacts MUST come through the architect/researcher/document-writer team via TeamCreate. Ask only one question at a time with no compounds and no sub-questions as examples. Honor user-initiated drill-downs fully before resuming your own line. Every task has exactly one parent branch — stack-linearity is absolute. NN-prefix must match run order. Always read `docs/adrs/**/*.md` at session start. Never fabricate sources or URLs. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
