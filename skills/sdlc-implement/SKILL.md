---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits, PRs, TDD, and third-party validation via a tester-coder agent team. Use after /sdlc-design to implement tasks one at a time.
model: opus
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: design -> **[implement]** -> complete

Resolve the task from direct path, task number, or plan directory. Called with no arguments or only a project path: read `MANIFEST.md` and walk the Build Order to the first epic whose status is not "Complete", then read that epic's `plan.md`, find the first task whose acceptance criteria are not all `[x]`, and use it. If no incomplete task remains in that epic, advance to the next epic in build order.

## Agent Team

Implementation MUST happen through a team via TeamCreate named `sdlc-implement-<project-slug>`. Spawn two permanent agents via `Agent`: `sdlc-tester` (opus) and `sdlc-coder` (opus). Each agent's AGENT.md carries its workflow and identity — do not re-specify here. Never implement code directly in the main conversation.

## Workflow

Load the task file, plan, spec, and project context (CLAUDE.md, .cursorrules, AGENTS.md, `docs/architecture/` if present, `docs/adrs/**/*.md`, and predecessor task files). Read `MANIFEST.md` and any upstream epic specs listed as dependencies so the implementer understands interfaces this epic consumes. Set up the dev branch: check out the existing local branch (and `git pull`) or create a new one from the task's `Base` field, falling back to `main` for squash-merged stacks. Assess progress via `[x]` markers and report: fresh start, resuming, or complete.

The tester writes the full red-test batch for every AC upfront — one table-driven unit test per observable behavior — defaulting to unit tests and only escalating to integration tests when the spec or architecture brief prescribes them. Integration test strategy (DB access, external services, test doubles) is an architect decision; ACs like "tests connect to the DB directly" get flagged back to the architect when unsanctioned. When integration tests are warranted, the tester reuses the project's existing constructors, factories, fixtures, and client/repo code as-is — never a new DB connection or setup helper when one already exists. Once the batch is committed red, the tester hands off every AC in one message and idles — no per-AC ping-pong. The coder works the batch continuously: smallest diff to green the next failing test, iterate to the next, refactor only once every targeted test is green. Skip tests and lint for non-behavioral changes like config or docs.

When the coder reports the full batch green and refactored, the tester runs the single **third-party validation** pass: lint on changed files using the first match from project script (`lint` in package.json, `lint` target in Taskfile, linter config in pyproject.toml), then language default (ESLint for JS/TS, ruff for Python, golangci-lint for Go); re-runs the full project test suite (not just new tests); and reads the spec side-by-side with the final code, citing the code that satisfies each clause. Lint errors count as failing tests — coder fixes, tester re-checks. Any spec clause without a code citation is drift, flagged back to the coder. Only when lint is clean, the full suite is green, and every spec clause has a home in the code does the tester approve the task.

On approval, bulk-update the task: mark every AC `[x]` in the task file, flip plan.md Status (Todo -> In Progress -> Done), then stage only the files that implement the task and STOP — tell the user to run `/commit` themselves. Never invoke `/commit` via Skill on the user's behalf. The user reads the staged diff and commits.

## Mid-Flight Revision

If review feedback is a requirement change — not a code tweak but a shift in what to build — pause tester and coder (no partial commits; leave the tree or stash) and invoke `/sdlc-design` scoped to the change. The design team re-spawns, reads the current manifest and in-flight work, and decides per remaining task: keep, revise, or void. Once the user confirms the updated plan, the implement team resumes on the current or revised task.

## Team Teardown

Once the task's PR is opened and the manifest is updated, shut down the team. Send `SendMessage` to `sdlc-tester` and `sdlc-coder` with `{type: "shutdown_request", reason: "Task complete."}`, wait for every `shutdown_approved` response, then call `TeamDelete` to remove the team and task directories. Do not skip teardown — leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-task (e.g., user stops mid-AC), leave the team running to preserve test and code context; teardown happens only at task completion or when the user explicitly ends the session.

## Completion

Once all criteria are complete, STOP and tell the user to run `/pr` themselves, noting the task's `Base` field as the target branch. Never invoke `/pr` via Skill on the user's behalf. Once the user provides the PR URL, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Update the manifest's status to "In Progress (N/M tasks done)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task from any epic. Only suggest `/sdlc-complete <project-dir>` when every epic in the manifest is marked Complete — never offer to complete an individual epic.

## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

NEVER implement code directly in the main conversation — all implementation MUST happen through the tester-coder team via TeamCreate. Always follow the TDD loop: failing tests before code, refactor only once green. Test through public interfaces. Never weaken a test to get it green. Never mark a task complete while any spec clause is unaccounted for. Never stage with `git add .` or `git add -A`. NEVER run `git commit`, `git push`, `gh pr create`, or `gh pr edit` directly, and NEVER invoke `/commit` or `/pr` via Skill — the user runs those themselves. Stage files and hand off; don't execute. Always assign PRs to the current user. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
