---
name: sdlc-implement
description: Execute one task from an SDLC implementation plan -- branch setup, a batched red-green TDD loop, third-party validation of spec against code and scenarios against tests, then a staged diff handed back for the user to commit and open a PR from. Use when building or coding the next task in a plan, resuming a task already part-done, or picking up where /sdlc-design left off.
argument-hint: "[task-path|task-number|project-dir]"
allowed-tools: "Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch --list:*)"
---

# Implement

Flow: design -> **[implement]** -> complete

Prove it, don't promise it -- no claim of "it works" without a test that would fail if it didn't. Smallest diff that tells the truth: if a change is bigger than the behaviour it delivers, stop and reconcile before typing further.

## Task Resolution

Resolve from direct path, task number, or plan directory. With no arguments or only a project path: read `MANIFEST.md`, walk Build Order to the first epic whose status is not "Complete", read that epic's `plan.md`, find the first task whose ACs are not all `[x]`, use it. If no incomplete task remains, advance to the next epic in build order.

Before resolving a task in any epic, validate preconditions: every epic listed under that epic's `spec.md` `## Dependencies` must be `Complete` in MANIFEST. If a dependency is not Complete, refuse to start -- name the missing dependency and tell the user to finish it first or invoke `/sdlc-design` to revise the graph.

## Context

Read the task file, `MANIFEST.md`, the epic's `spec.md` and `plan.md`, upstream epic specs listed as dependencies, project conventions (`CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `docs/architecture/`, `docs/adrs/**/*.md`), and predecessor task files. Fan wider reading out to one-shot `Explore` subagents -- existing test conventions, where a subsystem lives, what a helper is already called -- and read files directly where the exact text matters.

## Branch Setup

The task file names both: `Branch` is the branch to work on, `Base` is what it branches from. Check that branch out if it exists locally (and `git pull`), otherwise create it under exactly that name from `Base`, falling back for squash-merged stacks to the repo's default branch -- resolve it via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), not by assuming `main`. `/sdlc-complete` collects branches by that field, so one created under any other name is one it will not clean up. Assess progress via `[x]` markers and report: fresh start, resuming, or complete.

## Batched TDD Loop

Group the task's ACs into cohesive batches: one batch per AC for small tasks, or a few related ACs together when they share fixtures or shape. Never write a whole multi-AC task as one red batch -- later batches benefit from what earlier ones reveal about code shape.

Each batch runs red before green. Write the batch's tests, run the suite, and confirm they fail for the reason the scenario names. Then make the smallest edit that greens the next failing test and iterate until the batch is green. Refactor only once every targeted test in the batch is green and nothing else regressed.

Stage the batch's files with `git add <path>` as it closes. This is what puts new files in the index: a file that is neither tracked nor staged is invisible to `git diff <base>`, so the validator would read a diff missing exactly the code and tests just written. Report one line -- batch, ACs covered, files staged -- and start the next batch without pausing. The user commits when a set looks right to them.

**Test shape.** The task's ACs arrive as Given/When/Then scenarios copied from the epic spec. Each `Scenario` becomes one test over the behaviour it names, and each `Scenario Outline`'s `Examples` rows become the case table as written -- those rows are the cases the spec chose, so add a row where a boundary is uncovered but never drop or reword one. The scenario fixes the behaviour, never the construction: how the precondition is reached is yours to choose.

Default to table-driven unit tests -- one function with a case table per observable behaviour. Escalate to integration tests only where the spec or its architecture brief prescribes them; integration strategy (DB access, external services, test doubles vs. live) is a design decision, so an unspecified one routes to `/sdlc-design` rather than being settled here. When writing integration tests, reuse the project's existing constructors, factories, fixtures, and client/repo abstractions as-is -- never hand-roll a new DB connection, HTTP client, or setup helper when one already exists.

**End of batches.** Run lint on changed files -- first match from a project script (`lint` in package.json, a `lint` target in Taskfile, a linter config in pyproject.toml), then the language default: ESLint for JS/TS, ruff for Python, golangci-lint for Go. Lint errors count as failing tests. Re-run the full project suite, and update the task file's `Key Files` section to match the files actually changed (one line per file with the actual change), leaving it lint-clean. Skip tests and lint for non-behavioral changes (config, docs).

## Third-Party Validation

On a clean end-of-batches report, spawn a one-shot validator via the `Agent` tool (`subagent_type` `general-purpose`, `model` `opus`, `run_in_background: false` -- the verdict gates everything downstream), handing it only the epic's spec path, the task path, and the working-tree diff against the task's `Base` branch -- `git diff <base>`, never `<base>..HEAD`. Cold context, never this conversation, is what makes it third-party: it has not seen which tests you were pleased with.

It reads two axes off that one diff. Every clause the task file lists under `## Spec Requirements`, NFRs as well as FRs, against the production code. And the task's Acceptance Criteria against the tests, one test per `Scenario` and one case per `Examples` row -- those rows are the cases the spec chose, and a suite may add to them but never drop one. Only a `Scenario` becomes an Acceptance Criterion, so an NFR rides on the clause axis alone and the coverage axis never sees it. It returns JSON:

```json
{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}, {"clause": "NFR-2", "files": ["path:line"]}],
 "drift": [{"clause": "FR-2", "reason": "..."}],
 "covered": [{"scenario": "AC-1", "test": "path:line", "rows": 3}],
 "uncovered": [{"scenario": "AC-3", "reason": "..."}]}
```

Parse: `drift` and `uncovered` both empty -> approved. Any `drift` -> fix the production code against the named clause. Any `uncovered` -> write the missing test, or rebut the entry as already covered at a `file:line` the validator missed. Re-run lint and the full suite after either, stage what changed, and re-validate. Track rebuttals per scenario: a scenario returned uncovered again after one accepted rebuttal is a standoff -- STOP, put both positions to the user, and let them rule rather than looping. Skip the coverage axis only for the non-behavioral changes that already skip tests.

A backfilled test is proven the same way a red one is: break the behaviour the scenario names, watch that test go red, then restore and confirm green. Writing it, watching it pass, and reporting it covered proves nothing.

## On Approval

Mark every AC `[x]` in the task file, flip plan.md Status (Todo -> In Progress -> Done), confirm every file that implements the task is staged, and STOP -- tell the user to run `/commit` themselves; they read the staged diff, tests and code together, and commit.

## Mid-Flight Revision and Abandon Task

Two triggers route to `/sdlc-design` for keep/revise/void (its Mid-Flight Revision section owns the mechanics): a **requirement change** -- review feedback shifting what to build, not a code tweak -- or an **unbuildable task**, work that cannot be built as written. Either way, stash WIP (never commit a partial green), invoke `/sdlc-design` scoped to the change, and resume only after the user confirms the revised plan.

Two further blockers route there rather than being settled here, because design is not running alongside this: a factual or structural **ambiguity** -- naming, contract, technology choice -- and an AC that duplicates existing project code or prescribes unsanctioned test infrastructure. An edit growing past the spec sentence it implements is **scope drift**, ruled here as in-scope refinement or sent to `/sdlc-design` as a requirements shift; never silently widen scope to make a blocker disappear.

## Completion

Once all criteria are complete, STOP and tell the user to run `/pr` themselves, noting the task's `Base` field as the target branch. Once the user provides the PR URL, write `## PR\n\n[#<number>](<url>)` to the task file, preceded by a blank line and ending in one trailing newline so the file still lints clean. Update the manifest status to "In Progress (N/M)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task. Only suggest `/sdlc-complete <project-dir>` when every epic is Complete -- never offer to complete an individual epic.

## Rules

Never weaken a test to get it green, and never mark a task complete while any spec clause is unaccounted for or any AC scenario is still uncovered and unrebutted. Never skip the full-suite run at end of task. Never land an abstraction the spec did not ask for; prefer edits to new files, and existing conventions to invented ones. Never stage with `git add .` or `git add -A` -- name every path, so nothing unrelated rides along into the user's commit. Always assign PRs to the current user. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Handoff violation:** running `git commit`, `git push`, `gh pr create`, or `gh pr edit` here, or invoking `/commit` or `/pr` via Skill. The user reads the staged diff before it becomes a commit, and that read is the whole reason this skill stops. "Finish the task and open the PR" is a violation to act on, being a request for the work rather than an instruction to bypass the stop; staging only the implementing files, telling the user to run `/commit`, and writing the PR URL they hand back into the task file is the acceptable form.

**Red-first violation:** reporting a scenario covered by a test that has never been seen to fail. Greening an AC by editing the source first and adding a test that passes immediately is a violation, and so is a backfill written against behaviour that already exists; writing the batch's tests and running them red before coding, or breaking the named behaviour to watch a backfilled test go red, is acceptable.

**Abstraction violation:** structure the spec did not call for -- an interface with one implementation, a config knob nothing reads, a generic helper standing in front of a single caller. Extracting a `StorageBackend` interface where the spec names one store is a violation; extracting a helper because two tests in the current batch need the same setup is acceptable.

**Escalation violation:** writing tests against a spec sentence loose enough to yield contradictory suites, rather than routing it to `/sdlc-design` first. A clause reading "the cache expires promptly" admits two incompatible suites and is a violation to write against; "the cache expires 300 seconds after write" is testable and acceptable to proceed on.

Task-file edits land in someone's repo, so they lint there: blank lines around every heading, list, table, and fenced block; no trailing whitespace; one trailing newline. Where the project configures a markdown linter, run it on what you wrote and fix what it reports.

## User Input

$ARGUMENTS
