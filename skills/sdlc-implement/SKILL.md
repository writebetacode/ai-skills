---
name: sdlc-implement
description: Execute one task from an SDLC implementation plan -- branch setup, a batched red-green TDD loop, third-party validation of spec against code and scenarios against tests, then a staged diff handed back for the user to commit and open a PR from. Use when building or coding the next task in a plan, resuming a task already part-done, or picking up where /sdlc-design left off.
argument-hint: "[task-path|task-number|project-dir]"
allowed-tools: "Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch --list:*)"
---

# Implement

Flow: design -> **[implement]** -> complete

Never claim "it works" without a test that would fail if it didn't. Keep the diff as small as the behaviour it delivers; if it grows past that, stop and reconcile before writing more.

## Task Resolution

Resolve from a task path, task number, or plan directory. With no arguments or only a project path: read `MANIFEST.md`, follow Build Order to the first epic not "Complete", read its `plan.md`, and take the first task whose ACs aren't all `[x]`, moving to the next epic in build order if that one has none left.

Before starting, check every epic under the epic's `spec.md` `## Dependencies` is `Complete` in MANIFEST. If one isn't, refuse to start: name it and tell the user to finish it or run `/sdlc-design` to revise the graph.

## Context

Read:

- the task file, `MANIFEST.md`, and the epic's `spec.md` and `plan.md`
- specs of upstream dependency epics, and earlier task files
- project conventions: `CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `docs/architecture/`, `docs/adrs/**/*.md`

Hand wider questions (test conventions, where a subsystem lives, what a helper is called) to one-shot `Explore` subagents; read files directly where exact text matters.

## Branch Setup

The task's `Branch` field is the branch, `Base` is its parent. If the branch exists locally, check it out and `git pull`; otherwise create it under exactly that name from `Base`, falling back for squash-merged stacks to the default branch from `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`), never an assumed `main`. `/sdlc-complete` finds branches by that field, so any other name never gets cleaned up. From the `[x]` markers, report a fresh start, a resume, or already complete.

## Batched TDD Loop

Batch the ACs: one per batch for small tasks, or a few that share fixtures or shape. Never write a whole multi-AC task as one red batch. For each batch:

1. Write its tests, run the suite, and confirm they fail for the reason the scenario names.
2. Make the smallest edit that greens the next failing test; repeat until the batch is green.
3. Refactor only once every targeted test is green and nothing else regressed.
4. Stage its files with `git add <path>`; an untracked, unstaged file is invisible to `git diff <base>`, so the validator would miss it.
5. Report one line (batch, ACs covered, files staged) and go straight on. The user commits when a set looks right.

**Test shape.** ACs are Given/When/Then scenarios copied from the spec. Each `Scenario` becomes one test of its behaviour; each `Scenario Outline`'s `Examples` rows become the case table as written; they are the cases the spec chose. Add a row for an uncovered boundary, but never drop or reword one. The scenario fixes the behaviour, not the construction: reaching the precondition is up to you.

Default to table-driven unit tests, one function with a case table per observable behaviour. Write integration tests only where the spec or its architecture brief calls for them; an unspecified integration strategy (DB access, external services, doubles vs. live) is a design decision for `/sdlc-design`. Integration tests reuse the project's existing constructors, factories, fixtures, and client/repo abstractions; never hand-roll a DB connection, HTTP client, or setup helper that already exists.

**After the last batch:**

- Lint changed files with the first project script found (`lint` in package.json, a `lint` target in Taskfile, a linter config in pyproject.toml), else the language default: ESLint for JS/TS, ruff for Python, golangci-lint for Go. Lint errors count as failing tests.
- Run the full suite.
- Update the task file's `Key Files` to the files actually changed, one line each with the actual change.
- Skip tests and lint for non-behavioural changes (config, docs).

## Third-Party Validation

Once clean, spawn a one-shot validator with the `Agent` tool (`subagent_type` `general-purpose`, `model` `opus`, `run_in_background: false`), cold, without this conversation. Give it only the epic's spec path, the task path, and `git diff <base>` against the task's `Base` (never `<base>..HEAD`). It checks:

- every clause under the task's `## Spec Requirements`, NFRs included, against the production code;
- the Acceptance Criteria against the tests: one test per `Scenario`, one case per `Examples` row, extra cases allowed, none dropped. NFRs never become ACs, so they're checked against code only.

It returns JSON:

```json
{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}, {"clause": "NFR-2", "files": ["path:line"]}],
 "drift": [{"clause": "FR-2", "reason": "..."}],
 "covered": [{"scenario": "AC-1", "test": "path:line", "rows": 3}],
 "uncovered": [{"scenario": "AC-3", "reason": "..."}]}
```

- `drift` and `uncovered` both empty: approved.
- `drift`: fix the production code against the named clause.
- `uncovered`: write the missing test, or rebut it with a `file:line` the validator missed.

After either fix, re-run lint and the full suite, stage the changes, and re-validate. Track rebuttals per scenario: one returned uncovered again after an accepted rebuttal is a standoff, so STOP, give the user both positions, and let them rule. Skip the coverage check only for the non-behavioural changes that skip tests.

Prove a backfilled test like a red one: break the behaviour the scenario names, watch it fail, restore, confirm green.

## On Approval

Mark every AC `[x]`, move the plan.md Status along (Todo -> In Progress -> Done), confirm every implementing file is staged, and STOP. Tell the user to run `/commit` themselves.

## Mid-Flight Revision and Abandon Task

Route to `/sdlc-design` (its Mid-Flight Revision section keeps, revises, or voids tasks) on a **requirement change** (review feedback changing what to build, not a code tweak) or an **unbuildable task**. Stash work in progress (never commit a partial green), run `/sdlc-design` scoped to the change, and resume only after the user confirms the revised plan.

Also route there rather than deciding here: a factual or structural **ambiguity** (naming, contract, technology choice), or an AC that duplicates existing project code or prescribes unsanctioned test infrastructure. An edit growing past the spec sentence it implements is **scope drift**: rule it an in-scope refinement here, or send it to `/sdlc-design` as a requirements change. Never quietly widen scope to make a blocker go away.

## Completion

Once every criterion is done:

1. STOP and tell the user to run `/pr` themselves, with the task's `Base` as the target branch.
2. When they give you the PR URL, write `## PR\n\n[#<number>](<url>)` into the task file after a blank line, ending in one trailing newline.
3. Set the manifest status to "In Progress (N/M)" after each task, or "Complete" after the last.
4. After an epic's last task, report which downstream epics are now fully unblocked.
5. Show the PR URL and suggest the next task. Suggest `/sdlc-complete <project-dir>` only once every epic is Complete; never offer to complete a single epic.

## Rules

- Never weaken a test to make it pass.
- Never mark a task complete while a spec clause is unaccounted for, or an AC scenario is uncovered and unrebutted.
- Never skip the full-suite run at the end of a task.
- Never add an abstraction the spec didn't ask for. Prefer editing existing files, and existing conventions.
- Never stage with `git add .` or `git add -A`; name every path.
- Task-file edits must lint: blank lines around every heading, list, table, and fenced block, no trailing whitespace, one trailing newline. If the project configures a markdown linter, run it on what you wrote and fix what it reports.
- Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Handoff violation:** running `git commit`, `git push`, `gh pr create`, or `gh pr edit`, or invoking `/commit` or `/pr` through Skill. The user reads the staged diff before it becomes a commit, which is why this skill stops. "Finish the task and open the PR" asks for the work, not for skipping the stop, so committing or opening the PR is still a violation; staging only the implementing files, telling the user to run `/commit`, and recording the PR URL they give you is acceptable.

**Red-first violation:** calling a scenario covered by a test never seen to fail. Editing the source first and then adding a test that passes straight away is a violation, as is a backfill written against behaviour that already exists; running a batch's tests red before coding, or breaking the behaviour to watch a backfill fail, is acceptable.

**Abstraction violation:** structure the spec didn't ask for: an interface with one implementation, a config option nothing reads, a generic helper with one caller. Extracting a `StorageBackend` interface when the spec names one store is a violation; extracting a helper because two tests in the batch share setup is acceptable.

**Escalation violation:** writing tests against a spec sentence vague enough to allow contradictory suites instead of sending it to `/sdlc-design`. "The cache expires promptly" admits two incompatible suites and is a violation to write against; "the cache expires 300 seconds after write" is testable and fine.

## User Input

$ARGUMENTS
