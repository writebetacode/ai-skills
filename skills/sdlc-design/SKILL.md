---
name: sdlc-design
description: Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent. Use when starting a new feature that needs a written plan before implementation, or when a mid-flight revision forces the plan back onto the table.
argument-hint: "[what to build | project-dir]"
---

# Design

Flow: **[design]** -> implement -> complete

## Design Agent

Spec/plan authoring and all intake MUST happen through one long-lived agent, spawned at the very start before any questioning via the `Agent` tool with `subagent_type` `sdlc-architect`. Subagents run in the background by default, which is what this flow needs -- do not pass `run_in_background: false`. Its AGENT.md carries the workflow, identity, and model tier -- do not re-specify here.

If the agent cannot be spawned, it is not installed: name it, tell the user to install it, and stop. There is no fallback -- the Rules below forbid driving intake or authoring artifacts here, so a design run without the architect does not degrade into a main-thread one.

Reach it thereafter with `SendMessage` addressed to `sdlc-architect` -- the name comes from the agent definition, not from the spawn call -- which resumes it from its own transcript with the whole intake history intact. If a send by name fails to route, fall back to the `agentId` returned by the spawn call. Never re-spawn it mid-design with a fresh `Agent` call; that restarts it cold and loses every answer collected so far. The architect owns intake, research, the gates, signoff, and every artifact, including the multi-epic split it proposes for the user to confirm when scope decomposes into independent streams.

## Orchestrator Role

The main thread is a pure router: forward every user reply to `sdlc-architect` via `SendMessage` and relay the architect's next question back verbatim. Question discipline is the architect's -- its AGENT.md "Intake loop" is authoritative, and so is the call on when intake is complete. If `$ARGUMENTS` is empty, tell the architect on spawn so it opens by asking what to build.

Relay each question as your turn's final output and stop there, so the user can answer. Do not poll the architect or fill the wait with other work.

## Gates

The architect runs all seven signoff gates per its AGENT.md "Gates before signoff" -- they are absolute. Two consequences the orchestrator must surface: every task has exactly one parent (the repo's default branch or one prior branch; a `Base` naming two priors is flattened and the plan redone), and every NN-prefix matches run order for tasks and epic folders (mismatches renumbered before signoff, single-epic projects use `01-`).

## Concurrency Model

Within an epic, tasks are strictly linear: NN order is run order, every task stacks on one parent, the implement skill walks them in sequence. Across epics, parallelism is allowed: two epics in `epics.md` with disjoint dependency sets run concurrently via two `/sdlc-implement` sessions in separate checkouts, since each epic's first task branches from the default branch. Build Order is the recommended single-operator sequence; the dependency graph is the source of truth for fan-out.

## Mid-Flight Revision

When `$ARGUMENTS` names an existing project and the user requests a revision (architecture shift, scope change, reshape), enter revision mode. Never touch in-flight partial work -- tell the user to stash or leave the tree alone. Spawn a fresh `sdlc-architect` and route all revision intake through it under the orchestrator-as-router rule. The architect reads the manifest, completed task files, and in-progress work, then decides per remaining task: **keep** (unchanged), **revise** (updated spec -- mark `[revised: vN]` in MANIFEST and overwrite the task file), or **void** (no longer needed -- mark `[voided: <reason>]` in MANIFEST, leave the file in place for history). Append any new tasks with fresh NN-prefixes continuing the sequence. Update `adr.md` with the triggering decision. Confirm the updated plan with the user before returning them to `/sdlc-implement`.

## Project Structure

```text
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

`prd.md` is optional -- write it only for user-facing product requirements worth separating from the technical spec (the WHAT, not the HOW). When it exists, every epic's `spec.md` MUST cite it under `## Dependencies` ("PRD: prd.md") and trace each FR to a PRD section by quoted phrase or heading; an unreferenced PRD is wired in or deleted. `adr.md` is a required running log, one heading per project-level decision with context, decision, consequences. A decision strong enough to outlive the project (naming conventions, cross-cutting framework choice, data contract family) promotes to `docs/adrs/<YYYYMMDD>-<slug>.md` in the host repo, noted back in `adr.md`. Every session starts with the architect reading all existing `docs/adrs/**/*.md`.

## Agent Teardown

The architect idles after each reply and costs nothing while idle, so no shutdown handshake is needed -- after signoff and the `MANIFEST.md` write, simply stop messaging it. If it is stuck mid-run and must be terminated, `TaskStop` accepts its name.

## Completion

End with: "Design complete. Run `/sdlc-implement` to begin."

## Artifact Templates

The Spec, Plan, Task File, and Manifest formats live in `${CLAUDE_SKILL_DIR}/templates.md`. The architect reads them directly and fills them in verbatim; the orchestrator never authors an artifact, so it never needs them loaded.

## Rules

NEVER produce specs, plans, or task files in the main conversation, and NEVER drive intake there -- all artifacts and questions come through the `sdlc-architect` agent.

**Router violation:** relaying anything other than the architect's question as written -- merging two of its questions into one turn, softening a blunt one, appending your own follow-up, or answering on the user's behalf. Adding "and while we're here, what about auth?" beside the architect's question is a violation; sending its question alone and stopping is acceptable, even where you can see what it will ask next.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
