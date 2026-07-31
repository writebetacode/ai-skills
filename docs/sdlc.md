# SDLC workflow

A manifest-driven process from feature idea to merged code.

## Design

`/sdlc-design` is the single entry point: a persistent architect agent runs strict one-question-at-a-time intake and context7-backed research, authors all artifacts (spec, plan, tasks, MANIFEST), enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering, and handles mid-flight revisions via per-task keep/revise/void triage.

Every version or API claim carries a stamped source. context7 is the first stop, but its free tier allows 1,000 calls a month and a design session spends ten to fifteen, so a long-running project can exhaust it — and a library it has never indexed refuses just the same. Either way the architect falls back to WebSearch/WebFetch against the project's own docs, records the entry in the same form with the URL in place of the context7 source, marks it `[web fallback]`, and names the affected packages, so the weaker citation is visible rather than silent. What it never does is drop to an unsourced claim or one from memory; the citation regime is what makes a spec auditable months later.

Within an epic, tasks run linearly; across epics, disjoint dependency sets may run in parallel via two `/sdlc-implement` sessions in two checkouts.

## Implement

`/sdlc-implement` runs a persistent tester and coder through a batched TDD loop — tester writes an AC group's red tests, coder greens them, later batches learn from earlier ones — with the coordinator relaying every handoff, since subagents can only message `main`. It gates each task on its epic's dependencies being `Complete` in the manifest.

After lint and a full-suite pass, the coordinator (not the tester) spawns a fresh sub-agent as an unbiased third-party spec-vs-code validator; the task approves only when the validator reports no drift. Full mechanics live in the two SKILL.md files and the tester/coder AGENT.md files. The spec, plan, task, and manifest formats live in `skills/sdlc-design/templates.md`, which the architect reads directly rather than the orchestrator loading them.

## Commands

| Command | Phase | Description |
| --- | --- | --- |
| `/sdlc-design` | 1 — Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent; also handles mid-flight revisions via per-task keep/revise/void triage |
| `/sdlc-implement` | 2 — Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, epic-precondition gate, and third-party spec-vs-code validation via a fresh sub-agent; auto-picks the next task from the manifest when called without arguments |
| `/sdlc-complete` | 3 — Complete | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |

## File layout

The commands share a common file layout under `plans/` (keep this directory out of version control in your global gitignore):

```text
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

## Agents

| Agent | Model | Effort | Description |
| --- | --- | --- | --- |
| `sdlc-architect` | opus | xhigh | Design-phase architecture, intake, research, and document authoring; owns specs, plans, tasks, MANIFEST and enforces stack-linearity and NN-ordering |
| `sdlc-tester` | sonnet | high | TDD discipline — red-first batches and full-suite reruns — and rework of drift reported by the validator |
| `sdlc-coder` | sonnet | high | Smallest-diff implementation specialist |

`sdlc-architect` is spawned by `/sdlc-design` once per design session; `sdlc-tester` and `sdlc-coder` by `/sdlc-implement` once per task. Each is launched via the `Agent` tool (`subagent_type` set to the agent's name) and resumed thereafter with `SendMessage` addressed to that same name, which restores its full transcript — that persistence is what lets the tester write batch 2 knowing what batch 1 revealed. Each carries a one-line signature phrase that restates its hardest rule, and a frontmatter description naming both who invokes it and what it must never decide.

An agent that cannot be spawned is not installed, and both skills name it and stop rather than continuing without it — the same rule the forge skills follow. There is deliberately no fallback: `/sdlc-design` forbids driving intake or authoring artifacts in the main thread and `/sdlc-implement` forbids implementing there, so degrading into a main-thread run would do exactly what those rules exist to prevent. This is reachable in normal use, since `config.yml` can exclude an agent while keeping its skill, and Gemini receives the skills without any agents at all.

Unlike skills, agents pin `model` and `effort`: they spawn as fresh processes with no session to inherit from, so the tier is part of the role definition. Tester and coder run on `sonnet` — writing table-driven tests against a written spec and greening them with the smallest diff is routine coding, and the batched TDD loop is the flow's dominant token cost. Judgment-heavy roles stay on `opus`: the architect, and the one-shot spec-vs-code validator `/sdlc-implement` spawns.
