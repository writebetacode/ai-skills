# SDLC workflow

A manifest-driven process from feature idea to merged code.

## Design

`/sdlc-design` is the single entry point: a persistent architect agent runs strict one-question-at-a-time intake and context7-backed research, authors all artifacts (spec, plan, tasks, MANIFEST), enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering, and handles mid-flight revisions via per-task keep/revise/void triage.

Within an epic, tasks run linearly; across epics, disjoint dependency sets may run in parallel via two `/sdlc-implement` sessions in two checkouts.

## Implement

`/sdlc-implement` runs a persistent tester and coder through a batched TDD loop — tester writes an AC group's red tests, coder greens them, later batches learn from earlier ones — with the coordinator relaying every handoff, since subagents can only message `main`. It gates each task on its epic's dependencies being `Complete` in the manifest.

After lint and a full-suite pass, the coordinator (not the tester) spawns a fresh sub-agent as an unbiased third-party spec-vs-code validator; the task approves only when the validator reports no drift. Full mechanics live in the two SKILL.md files and the tester/coder AGENT.md files.

## Commands

| Command | Phase | Description |
|---|---|---|
| `/sdlc-design` | 1 — Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent; also handles mid-flight revisions via per-task keep/revise/void triage |
| `/sdlc-implement` | 2 — Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, epic-precondition gate, and third-party spec-vs-code validation via a fresh sub-agent; auto-picks the next task from the manifest when called without arguments |
| `/sdlc-complete` | 3 — Complete | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |

## File layout

The commands share a common file layout under `plans/` (keep this directory out of version control in your global gitignore):

```
plans/
  <project-slug>/                   # project folder (from /sdlc-design, no date prefix)
    MANIFEST.md                     # central control document (always present)
    prd.md                          # optional -- WHAT users need (product requirements)
    adr.md                          # running log of project-level architecture decisions
    epics.md                        # epic list, dependency graph, and build order (multi-epic)
    research/<topic>.md             # architect's citation notes
    epics/
      NN-<epic-slug>/               # NN-prefix matches Build Order
        spec.md                     # technical specification
        plan.md                     # implementation plan
        tasks/
          01-<task-name>.md         # NN-prefix matches run order
          02-<task-name>.md
  complete/
    YYYYMMDD-<project-slug>/        # archived by /sdlc-complete (date appended on archive)
```

Project-level ADRs live in `adr.md`; decisions strong enough to outlive the project promote to the host repo under `docs/adrs/<YYYYMMDD>-<slug>.md` and load at the start of every future design session. `prd.md` is optional, but when present every epic's `spec.md` MUST cite it under `## Dependencies` and trace each FR to a PRD section — unreferenced PRDs drop at signoff. Each task drives one branch and one PR, stacked on the previous task's branch.
