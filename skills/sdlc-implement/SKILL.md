---
name: sdlc-implement
description: Execute one task from an SDLC implementation plan -- branch setup, a batched red-green TDD loop through persistent tester and coder agents, third-party validation of spec against code and scenarios against tests, then a staged diff handed back for the user to commit and open a PR from. Use when building or coding the next task in a plan, resuming a task already part-done, or picking up where /sdlc-design left off.
argument-hint: "[task-path|task-number|project-dir]"
---

# Implement

Flow: design -> **[implement]** -> complete

## Task Resolution

Resolve from direct path, task number, or plan directory. With no arguments or only a project path: read `MANIFEST.md`, walk Build Order to the first epic whose status is not "Complete", read that epic's `plan.md`, find the first task whose ACs are not all `[x]`, use it. If no incomplete task remains, advance to the next epic in build order.

Before resolving a task in any epic, validate preconditions: every epic listed under that epic's `spec.md` `## Dependencies` must be `Complete` in MANIFEST. If a dependency is not Complete, refuse to start -- name the missing dependency and tell the user to finish it first or invoke `/sdlc-design` to revise the graph.

## Implementation Agents

Spawn both agents once per task via the `Agent` tool with `subagent_type` `sdlc-tester` and `sdlc-coder`. Each agent's AGENT.md carries its workflow, identity, and model tier -- do not re-specify here. Subagents run in the background by default, which is what this flow needs -- do not pass `run_in_background: false`.

If either cannot be spawned, it is not installed: name it, tell the user to install it, and stop. There is no fallback -- the Rules below forbid implementing here, so a task missing an agent does not degrade into a main-thread one.

Reach an already-spawned agent with `SendMessage` addressed to `sdlc-tester` or `sdlc-coder` -- the name comes from the agent definition, not from the spawn call -- which resumes it from its own transcript with full context intact. This is what makes the batched loop work: the tester writing batch 2 still remembers what batch 1 revealed. If a send by name fails to route, fall back to the `agentId` returned by that agent's spawn call. Never re-spawn an agent mid-task with a fresh `Agent` call; that discards its context and restarts it cold.

## Workflow

**Coordinator reads.** Only `MANIFEST.md` and the task file. Do not read spec, plan, ADRs, architecture docs, CLAUDE.md, .cursorrules, AGENTS.md, upstream epic specs, or predecessor tasks in the main thread -- the tester and coder own that reading list, and the coordinator stays a thin dispatcher to keep compaction at bay.

**Branch setup.** The task file names both: `Branch` is the branch to work on, `Base` is what it branches from. Check that branch out if it exists locally (and `git pull`), otherwise create it under exactly that name from `Base`, falling back for squash-merged stacks to the repo's default branch -- resolve it via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), not by assuming `main`. `/sdlc-complete` collects branches by that field, so one created under any other name is one it will not clean up. Assess progress via `[x]` markers and report: fresh start, resuming, or complete.

**Handoff.** Hand each agent the task path plus the project root in its spawn prompt; they load their own context from there.

**Batched TDD loop.** The coordinator relays between the two: tester writes batch 1's red tests, commits red, and reports; coordinator forwards to the coder via `SendMessage`; coder greens the batch and reports; coordinator forwards back; tester writes batch 2 informed by what batch 1 revealed; repeat until every AC has a green batch. Forward the substance of each report rather than a summary -- the receiving agent acts on it. Batch shape, test-style defaults, and integration/reuse rules live in the tester and coder AGENT.md; the coordinator owns only the checkpoint sequence. Skip tests and lint for non-behavioral changes (config, docs).

**End of batches.** Tester runs lint on changed files per its AGENT.md, re-runs the full project suite, and reconciles the task file's `Key Files`. Lint errors count as failing tests. Tester reports `batches green, lint clean, suite green, key files reconciled` and idles.

**Third-party validation (coordinator-owned).** On the tester's clean report, the coordinator spawns a one-shot validator via the `Agent` tool (`subagent_type` `general-purpose`, `model` `opus`, `run_in_background: false` -- the verdict gates everything downstream), handing it only the epic's spec path, the task path, and the working-tree diff against the task's `Base` branch -- `git diff <base>`, never `<base>..HEAD`. Cold context, never the tester's or coder's conversation, is what makes it third-party. The range is load-bearing: the tester commits its red batches while the coder's green work stays uncommitted until the user's `/commit`, so a commit range shows the validator the tests with none of the code they cover, and every clause comes back as drift.

It reads two axes off that one diff. Every clause the task file lists under `## Spec Requirements`, NFRs as well as FRs, against the production code. And the task's Acceptance Criteria against the tests, one test per `Scenario` and one case per `Examples` row -- those rows are the cases the architect chose, and the tester may add to them but never drop one. Only a `Scenario` becomes an Acceptance Criterion, so an NFR rides on the clause axis alone and the coverage axis never sees it. It returns JSON:

```json
{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}, {"clause": "NFR-2", "files": ["path:line"]}],
 "drift": [{"clause": "FR-2", "reason": "..."}],
 "covered": [{"scenario": "AC-1", "test": "path:line", "rows": 3}],
 "uncovered": [{"scenario": "AC-3", "reason": "..."}]}
```

Parse: `drift` and `uncovered` both empty -> approved. Any `drift` -> route to the tester with the drift list, which re-engages the coder. Any `uncovered` -> route to the tester, which either writes the missing test or rebuts the entry as already covered at a `file:line` the validator missed. Re-validate after either, and track rebuttals per scenario: a scenario returned uncovered again after one accepted rebuttal is a standoff -- STOP, put both positions to the user, and let them rule rather than looping. Skip the coverage axis only for the non-behavioral changes that already skip tests.

**On approval.** Mark every AC `[x]` in the task file, flip plan.md Status (Todo -> In Progress -> Done), stage only the files that implement the task, and STOP -- tell the user to run `/commit` themselves; they read the staged diff and commit.

**Agent reports.** Agents report per their own "Reporting to the Coordinator" sections. The coordinator receives `approved` or a blocker list keyed by AC or spec clause; citations stay in the tester's context so the main thread stays cold.

## Mid-Flight Revision and Abandon Task

Two triggers route to `/sdlc-design` for keep/revise/void (its Mid-Flight Revision section owns the mechanics): a **requirement change** -- review feedback shifting what to build, not a code tweak -- or an **unbuildable task** -- the coder reports `unbuildable: <reason>`, which you relay to the tester to confirm or downgrade to a fixable blocker. Either way, pause tester and coder, stash WIP (never commit a partial green), invoke `/sdlc-design` scoped to the change, and resume only after the user confirms the revised plan.

Agents label blockers rather than routing them, since neither can reach the other or the architect. Dispatch by label: `scope-drift` relays to the tester, which rules in-scope refinement or requirements shift; `ambiguity` and confirmed `unbuildable` route to `/sdlc-design`, because the architect does not run during implementation.

## Agent Teardown

Background agents idle after reporting and cost nothing while idle, so no shutdown handshake is needed. Once the validator approves and the task file and plan.md are updated, simply stop messaging them. If an agent is stuck mid-run and must be terminated, `TaskStop` accepts its name. Leave both agents alive until the task is fully approved -- the `/commit` and `/pr` handoffs happen in a later user turn, and a re-spawn to fix late drift would start cold.

## Completion

Once all criteria are complete, STOP and tell the user to run `/pr` themselves, noting the task's `Base` field as the target branch. Once the user provides the PR URL, write `## PR\n\n[#<number>](<url>)` to the task file, preceded by a blank line and ending in one trailing newline so the file still lints clean (do not commit). Update the manifest status to "In Progress (N/M)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task. Only suggest `/sdlc-complete <project-dir>` when every epic is Complete -- never offer to complete an individual epic.

## Rules

NEVER implement code directly in the main conversation -- all implementation through the tester and coder agents (TDD discipline lives in their AGENT.md). Never mark a task complete while any spec clause is unaccounted for, or while any AC scenario is still uncovered and unrebutted. Never stage with `git add .` or `git add -A`. Always assign PRs to the current user. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Handoff violation:** running `git commit`, `git push`, `gh pr create`, or `gh pr edit` here, or invoking `/commit` or `/pr` via Skill. The user reads the staged diff before it becomes a commit, and that read is the whole reason this skill stops. "Finish the task and open the PR" is a violation to act on, being a request for the work rather than an instruction to bypass the stop; staging only the implementing files, telling the user to run `/commit`, and writing the PR URL they hand back into the task file is the acceptable form.

## User Input

$ARGUMENTS
