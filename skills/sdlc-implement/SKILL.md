---
name: sdlc-implement
description: Execute one task from an SDLC implementation plan -- branch setup, a batched red-green TDD loop, third-party validation of spec against code and scenarios against tests, then a staged diff handed back for the user to commit and open a PR from. Use when building or coding the next task in a plan, resuming a task already part-done, or picking up where /sdlc-design left off.
argument-hint: "[task-path|task-number|project-dir]"
allowed-tools: "Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch --list:*)"
---

# Implement

Flow: design -> **[implement]** -> complete

Never claim "it works" without a test that would fail if it didn't. Keep the diff as small as the behaviour it delivers. If it grows past that, stop and reconcile before writing more.

## Task Resolution

Resolve from a direct path, a task number, or a plan directory. With no arguments, or only a project path, read `MANIFEST.md`, follow Build Order to the first epic that isn't "Complete", read its `plan.md`, and take the first task whose ACs aren't all `[x]`. If that epic has no incomplete task, move to the next epic in build order.

Before starting a task, check that every epic listed under its epic's `spec.md` `## Dependencies` is `Complete` in MANIFEST. If one isn't, refuse to start. Name the missing dependency and tell the user to finish it first or run `/sdlc-design` to revise the graph.

## Context

Read the task file, `MANIFEST.md`, the epic's `spec.md` and `plan.md`, the specs of upstream dependency epics, project conventions (`CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `docs/architecture/`, `docs/adrs/**/*.md`), and earlier task files. Hand wider questions to one-shot `Explore` subagents (test conventions, where a subsystem lives, what a helper is called), and read files directly where the exact text matters.

## Branch Setup

The task file's `Branch` field is the branch to work on and `Base` is what it branches from. If the branch exists locally, check it out and `git pull`. Otherwise create it under exactly that name from `Base`. For squash-merged stacks, fall back to the default branch, found with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), never assumed to be `main`. `/sdlc-complete` finds branches by that field, so a branch with any other name never gets cleaned up. Check the `[x]` markers and report whether this is a fresh start, a resume, or already complete.

## Batched TDD Loop

Group the task's ACs into batches: one AC per batch for small tasks, or a few related ACs that share fixtures or shape. Never write a whole multi-AC task as one red batch.

In each batch, write the tests, run the suite, and confirm they fail for the reason the scenario names. Then make the smallest edit that greens the next failing test, and repeat until the batch is green. Refactor only once every targeted test is green and nothing else has regressed.

When a batch closes, stage its files with `git add <path>`. A file that is neither tracked nor staged doesn't show up in `git diff <base>`, so the validator would miss it. Report one line (batch, ACs covered, files staged) and go straight on to the next batch. The user commits when they're happy with a set.

**Test shape.** The ACs are Given/When/Then scenarios copied from the epic spec. Each `Scenario` becomes one test of the behaviour it names. Each `Scenario Outline`'s `Examples` rows become the case table as written. You may add a row for an uncovered boundary, but never drop or reword one. The scenario fixes the behaviour, not the construction: how you reach the precondition is up to you.

Default to table-driven unit tests, one function with a case table per observable behaviour. Write integration tests only where the spec or its architecture brief calls for them. An integration strategy that isn't specified (DB access, external services, test doubles vs. live) is a design decision, so route it to `/sdlc-design`. In integration tests, reuse the project's existing constructors, factories, fixtures, and client/repo abstractions. Never hand-roll a new DB connection, HTTP client, or setup helper when one already exists.

**After the last batch.** Lint the changed files. Use the first project script you find (`lint` in package.json, a `lint` target in Taskfile, a linter config in pyproject.toml), falling back to the language default: ESLint for JS/TS, ruff for Python, golangci-lint for Go. Lint errors count as failing tests. Run the full suite again. Update the task file's `Key Files` section to list the files actually changed, one line per file with the actual change. Skip tests and lint for non-behavioural changes (config, docs).

## Third-Party Validation

Once the last batch is clean, spawn a one-shot validator with the `Agent` tool (`subagent_type` `general-purpose`, `model` `opus`, `run_in_background: false`). Give it only the epic's spec path, the task path, and the working-tree diff against the task's `Base`: `git diff <base>`, never `<base>..HEAD`. It must start cold, without this conversation.

It checks two things in that diff. First, every clause under the task file's `## Spec Requirements`, NFRs included, against the production code. Second, the Acceptance Criteria against the tests: one test per `Scenario` and one case per `Examples` row, where a suite may add cases but never drop one. NFRs never become Acceptance Criteria, so they are only checked against the code. It returns JSON:

```json
{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}, {"clause": "NFR-2", "files": ["path:line"]}],
 "drift": [{"clause": "FR-2", "reason": "..."}],
 "covered": [{"scenario": "AC-1", "test": "path:line", "rows": 3}],
 "uncovered": [{"scenario": "AC-3", "reason": "..."}]}
```

If `drift` and `uncovered` are both empty, the task is approved. For each `drift` entry, fix the production code against that clause. For each `uncovered` entry, write the missing test, or rebut it by pointing to a `file:line` the validator missed. After either, re-run lint and the full suite, stage the changes, and validate again. Track rebuttals per scenario. If a scenario comes back uncovered again after one accepted rebuttal, STOP, give the user both positions, and let them decide. Skip the coverage check only for the non-behavioural changes that skip tests.

Prove a backfilled test the same way as a red one: break the behaviour the scenario names, watch the test fail, then restore it and confirm green.

## On Approval

Mark every AC `[x]` in the task file, move the plan.md Status along (Todo -> In Progress -> Done), confirm every file that implements the task is staged, and STOP. Tell the user to run `/commit` themselves.

## Mid-Flight Revision and Abandon Task

Two situations go to `/sdlc-design` to keep, revise, or void tasks (its Mid-Flight Revision section owns how): a **requirement change**, where review feedback changes what to build rather than how the code looks, and an **unbuildable task** that can't be built as written. In both cases, stash the work in progress (never commit a partial green), run `/sdlc-design` scoped to the change, and resume only once the user confirms the revised plan.

Two blockers also go to `/sdlc-design` instead of being decided here: a factual or structural **ambiguity** (naming, contract, technology choice), and an AC that duplicates existing project code or prescribes test infrastructure nobody sanctioned. An edit that grows past the spec sentence it implements is **scope drift**. Decide here whether it's an in-scope refinement, or send it to `/sdlc-design` as a requirements change. Never quietly widen scope to make a blocker go away.

## Completion

Once every criterion is done, STOP and tell the user to run `/pr` themselves, with the task's `Base` as the target branch. When the user gives you the PR URL, write `## PR\n\n[#<number>](<url>)` into the task file after a blank line, ending with one trailing newline. After each task, set the manifest status to "In Progress (N/M)", or "Complete" after the last task. When an epic's last task is done, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next task. Suggest `/sdlc-complete <project-dir>` only once every epic is Complete. Never offer to complete a single epic.

## Rules

Never weaken a test to make it pass. Never mark a task complete while a spec clause is unaccounted for, or an AC scenario is uncovered and not rebutted. Never skip the full-suite run at the end of a task. Never add an abstraction the spec didn't ask for. Prefer editing existing files to creating new ones, and existing conventions to new ones. Never stage with `git add .` or `git add -A`: name every path. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

Task-file edits must lint cleanly: blank lines around every heading, list, table, and fenced block, no trailing whitespace, and one trailing newline. If the project configures a markdown linter, run it on what you wrote and fix what it reports.

**Handoff violation:** running `git commit`, `git push`, `gh pr create`, or `gh pr edit`, or invoking `/commit` or `/pr` through Skill. The user reads the staged diff before it becomes a commit, which is why this skill stops. "Finish the task and open the PR" asks for the work, not for skipping the stop, so going on to commit or open the PR is still a violation. Staging only the implementing files, telling the user to run `/commit`, and writing the PR URL they give you into the task file is acceptable.

**Red-first violation:** calling a scenario covered by a test that has never been seen to fail. Editing the source first and then adding a test that passes straight away is a violation, and so is a backfilled test written against behaviour that already exists. Writing a batch's tests and running them red before coding, or breaking the behaviour to watch a backfilled test fail, is acceptable.

**Abstraction violation:** structure the spec didn't ask for, such as an interface with one implementation, a config option nothing reads, or a generic helper with a single caller. Extracting a `StorageBackend` interface when the spec names one store is a violation. Extracting a helper because two tests in the current batch need the same setup is acceptable.

**Escalation violation:** writing tests against a spec sentence vague enough to allow contradictory test suites, instead of sending it to `/sdlc-design` first. "The cache expires promptly" allows two incompatible suites, so writing against it is a violation. "The cache expires 300 seconds after write" is testable and fine to proceed on.

## User Input

$ARGUMENTS
