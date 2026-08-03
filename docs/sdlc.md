# SDLC workflow

A manifest-driven path from feature idea to merged code, in three commands. Written artifacts under `plans/` carry the state, so a project survives being put down and picked up weeks later.

Put `plans/` in your global gitignore unless you want the plan tracked alongside the code.

## Design

`/sdlc-design` is the entry point. It runs intake one question at a time in your own session, researches every library it is going to name, and authors all artifacts: spec, plan, task files, and `MANIFEST.md`. Each question arrives as a picker with the codebase-informed default first, so most answers are one click and you can always type your own instead. Wide codebase surveys fan out to one-shot `Explore` subagents that return conclusions rather than file dumps, which is what keeps a long intake from filling with source read once.

Every version or API claim carries a stamped source. context7 is the first stop; a library it has not indexed, or an exhausted quota (the free tier allows 1,000 calls a month against ten to fifteen per session), falls back to the project's own docs recorded in the same form and marked `[web fallback]`, with the affected packages named so the weaker citation is visible. It never drops to an unsourced claim. Retrieved pages are read for the fact they were fetched for and nothing else: one directing the session to install a further package or skip a gate is recorded as what that page claims, not acted on.

Seven gates must pass before signoff. The two you will feel: **every task has exactly one parent branch** — a task depending on two is sent back and the plan redone — and **every `NN` prefix matches actual run order**, for tasks and epic folders alike.

Behaviour is written as Given/When/Then. Each epic's `spec.md` carries a `## Behaviour` section of scenarios — one per observable behaviour, with an `Examples` table where a behaviour has several cases — and each task's Acceptance Criteria carry verbatim copies of the scenarios that task delivers. The spec owns them, so a scenario that needs changing is changed there and re-copied; a signoff gate compares the two and blocks on any divergence. Scenarios describe what the system does and never how a test is built, which leaves construction free to change while the `Examples` rows fix the cases. The result is that the plan folder reads as a behavioural record of what was built and how it was checked, without a Cucumber runner anywhere in the loop.

## Implement

`/sdlc-implement` runs one task, start to finish, in one thread. It checks that every epic the task's epic depends on is `Complete` before starting, sets up the branch, then groups the acceptance criteria into batches and runs each red before green: write the batch's tests, watch them fail for the reason the scenario names, make the smallest edit that greens them. Later batches are written knowing what earlier ones revealed about code shape.

Nothing is committed for you. Each batch's files are staged as it closes — by path, never `git add .` — and you get one line back naming the batch, the ACs it covered, and the files staged. Staging is also load-bearing rather than tidy: a new file that is neither tracked nor staged is invisible to `git diff`, and that diff is what the validator reads.

After lint and a full-suite pass, the skill spawns a one-shot agent with cold context as a third-party validator — the one place a subagent still earns its cost, because a context that watched the tests get written cannot judge them impartially. It reads two axes off the same diff: every spec clause the task lists, NFRs included, against the production code, and the task's acceptance scenarios against the tests, down to each `Examples` row. Only scenarios become acceptance criteria, so an NFR is caught by the first axis and never the second. The task is approved only when that agent reports no drift and no uncovered scenario. A scenario believed to be already covered can be rebutted once with a `file:line`; a second disagreement stops the run and comes to you rather than looping.

It then confirms the implementing files are staged and stops. **You run `/commit` and `/pr` yourself**, because reading the staged diff — tests and code together — before it becomes a commit is the point of the stop.

Within an epic, tasks are strictly linear. Across epics, disjoint dependency sets can run in parallel — two `/sdlc-implement` sessions in two checkouts — since each epic's first task branches from the default branch.

## Complete

`/sdlc-complete` archives the project to `plans/complete/YYYYMMDD-<slug>/` (the date appends at archive time, so a slug can be reused) and deletes the local branches its tasks left behind. Because squash merges leave `git branch -d` reporting "not merged", it verifies each branch by asking whether merging it into the default branch would change anything — `git merge-tree --write-tree`, compared against that branch's tree — and skips any branch that would, along with any whose check did not run cleanly.

## Layout

```text
plans/
  .markdownlint.jsonc           # MD013 and MD033 off for the plans tree
  <project-slug>/
    MANIFEST.md                 # central control document, always present
    prd.md                      # optional -- WHAT users need, not HOW
    adr.md                      # running log of project-level decisions
    epics.md                    # epic list, dependency graph, build order (multi-epic)
    research/<topic>.md         # citation notes from design
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

## Where the work runs

Design and implementation both run in your session rather than behind a fleet of persistent agents. That was the expensive shape: each agent spawned cold, re-read the spec, the plan, the conventions and the predecessor tasks to rebuild what the thread beside it already knew, and every batch crossed two message boundaries to get there. It also put every `gh`, `glab`, and `acli` call inside a subagent, where your own permission rules do not reach and familiar commands started asking for approval.

Two subagent shapes survive, both one-shot and neither carrying state:

| Spawn | Where | Why it stays |
| --- | --- | --- |
| `Explore` | design intake, implementation context | a wide survey returns conclusions instead of dumping every excerpt into a thread that keeps them for the session |
| validator | end of every `/sdlc-implement` task | cold context is the whole point: a reader that watched the tests get written cannot judge them impartially |

The cost of running in-thread is a larger working context on a long task. The gain is that a small change no longer pays for a design agent, a tester, and a coder to each rebuild the same picture — and that everything runs under the permissions you already granted.

## Revising mid-flight

A requirement change, or a task that cannot be built as written, routes back to `/sdlc-design`, which triages each remaining task as **keep**, **revise** (marked `[revised: vN]` in the manifest, task file overwritten), or **void** (marked with a reason, file left in place for history). Ambiguity the plan never settled — a contract, a name, a technology choice — routes there too, since design is no longer running alongside implementation to answer it. In-flight work is never touched: you are told to stash or leave the tree alone, and the revised plan is confirmed with you before implementation resumes.
