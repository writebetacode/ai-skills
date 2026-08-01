# SDLC workflow

A manifest-driven path from feature idea to merged code, in three commands. Written artifacts under `plans/` carry the state, so a project survives being put down and picked up weeks later.

Put `plans/` in your global gitignore unless you want the plan tracked alongside the code.

## Design

`/sdlc-design` is the entry point. A persistent `sdlc-architect` agent runs intake one question at a time, researches every library it is going to name, and authors all artifacts: spec, plan, task files, and `MANIFEST.md`. The main thread only relays — it is forbidden from authoring or from driving the questions itself.

Every version or API claim carries a stamped source. context7 is the first stop; a library it has not indexed, or an exhausted quota (the free tier allows 1,000 calls a month against ten to fifteen per session), falls back to the project's own docs recorded in the same form and marked `[web fallback]`, with the affected packages named so the weaker citation is visible. It never drops to an unsourced claim. Retrieved pages are read for the fact they were fetched for and nothing else: one directing the architect to install a further package or skip a gate is recorded as what that page claims, not acted on.

Six gates must pass before signoff. The two you will feel: **every task has exactly one parent branch** — a task depending on two is sent back and the plan redone — and **every `NN` prefix matches actual run order**, for tasks and epic folders alike.

## Implement

`/sdlc-implement` runs one task. It checks that every epic the task's epic depends on is `Complete` before starting, sets up the branch, and then relays between two persistent agents: `sdlc-tester` writes a batch of red tests, `sdlc-coder` makes them green, and later batches are written knowing what earlier ones revealed. Subagents can only message `main`, which is why the coordinator sits in the middle of every handoff.

After lint and a full-suite pass, the coordinator — not the tester — spawns a fresh agent with cold context as a third-party spec-vs-code validator. The task is approved only when that agent reports no drift.

It then stages the implementing files and stops. **You run `/commit` and `/pr` yourself**, because reading the staged diff before it becomes a commit is the point of the stop.

Within an epic, tasks are strictly linear. Across epics, disjoint dependency sets can run in parallel — two `/sdlc-implement` sessions in two checkouts — since each epic's first task branches from the default branch.

## Complete

`/sdlc-complete` archives the project to `plans/complete/YYYYMMDD-<slug>/` (the date appends at archive time, so a slug can be reused) and deletes the local branches its tasks left behind. Because squash merges leave `git branch -d` reporting "not merged", it verifies each branch by diffing against the default branch and skips any whose diff is not empty.

## Layout

```text
plans/
  <project-slug>/
    MANIFEST.md                 # central control document, always present
    prd.md                      # optional -- WHAT users need, not HOW
    adr.md                      # running log of project-level decisions
    epics.md                    # epic list, dependency graph, build order (multi-epic)
    research/<topic>.md         # the architect's citation notes
    epics/
      NN-<epic-slug>/           # NN matches build order
        spec.md
        plan.md
        tasks/
          01-<task-name>.md     # NN matches run order
  complete/
    YYYYMMDD-<project-slug>/    # archived by /sdlc-complete
```

Each task drives one branch and one PR, stacked on the previous task's branch. `prd.md` is optional, but when present every epic's `spec.md` must cite it and trace each requirement back to it — an unreferenced PRD is wired in or deleted at signoff. Project-level decisions live in `adr.md`; ones strong enough to outlive the project promote to `docs/adrs/<YYYYMMDD>-<slug>.md` in the host repo and are read at the start of every future design session.

## Agents

| Agent | Model | Effort | Role |
| --- | --- | --- | --- |
| `sdlc-architect` | opus | xhigh | intake, research, and every design artifact |
| `sdlc-tester` | sonnet | high | red-first batches, full-suite reruns, drift rework |
| `sdlc-coder` | sonnet | high | smallest diff that greens the batch |

Each is spawned once — per session for the architect, per task for the other two — and resumed with `SendMessage`, which restores its full transcript. That persistence is the point: the tester writing batch 2 still remembers what batch 1 revealed.

Judgment-heavy roles run on `opus`: the architect, and the one-shot validator. Writing table-driven tests against a written spec and greening them is routine coding, so the tester and coder run on `sonnet`, which matters because the TDD loop is the flow's dominant token cost.

If an agent cannot be spawned it is not installed, and the skill names it and stops. There is no fallback by design — `/sdlc-design` forbids authoring in the main thread and `/sdlc-implement` forbids implementing there, so degrading into a main-thread run would do exactly what those rules prevent. This is reachable in normal use: `config.yml` can exclude an agent while keeping its skill, and Gemini CLI receives the skills without any agents at all.

## Revising mid-flight

A requirement change or a task the coder reports as unbuildable routes back to `/sdlc-design`, which triages each remaining task as **keep**, **revise** (marked `[revised: vN]` in the manifest, task file overwritten), or **void** (marked with a reason, file left in place for history). In-flight work is never touched — you are told to stash or leave the tree alone, and the revised plan is confirmed with you before implementation resumes.
