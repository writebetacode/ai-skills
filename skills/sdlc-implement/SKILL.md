---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits, PRs, TDD, and third-party validation via a tester-coder agent team. Use after /sdlc-design to implement tasks one at a time.
model: opus
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: design -> **[implement]** -> complete

Resolve the task from direct path, task number, or plan directory. Called with no arguments or only a project path: read `MANIFEST.md` and walk the Build Order to the first epic whose status is not "Complete", then read that epic's `plan.md`, find the first task whose acceptance criteria are not all `[x]`, and use it. If no incomplete task remains in that epic, advance to the next epic in build order.

Before resolving a task in any epic, validate the epic's preconditions: every epic listed under that epic's `spec.md` `## Dependencies` must be marked `Complete` in MANIFEST. If a dependency is not Complete, refuse to start the task — name the missing dependency and tell the user to finish it first or invoke `/sdlc-design` to revise the dependency graph. This mirrors the stack-linearity gate at design time.

## Agent Team

Implementation MUST happen through a team via TeamCreate named `sdlc-implement-<project-slug>`. Spawn two permanent agents via `Agent`: `sdlc-tester` (opus) and `sdlc-coder` (opus). Each agent's AGENT.md carries its workflow and identity — do not re-specify here. Never implement code directly in the main conversation.

## Workflow

Resolve the task from `MANIFEST.md` and the task file only — do not read spec, plan, ADRs, architecture docs, CLAUDE.md, .cursorrules, AGENTS.md, upstream epic specs, or predecessor tasks in the main thread. The tester and coder AGENT.md files own that reading list; the coordinator stays a thin dispatcher to keep compaction at bay. Set up the dev branch: check out the existing local branch (and `git pull`) or create a new one from the task's `Base` field, falling back to `main` for squash-merged stacks. Assess progress via `[x]` markers and report: fresh start, resuming, or complete.

Before handoff, read the task file header for an optional architect-set `Depth: ultrathink` marker. Hand each agent the task path plus the project root; they load their own context. When `Depth: ultrathink` is set, prepend `ultrathink — ` to the handoff message to both the tester and the coder. The tester groups ACs into cohesive batches (one batch per AC for small tasks, or a few related ACs grouped together when they share fixtures or shape) — table-driven unit tests by default, only escalating to integration tests when the spec or architecture brief prescribes them. Integration test strategy (DB access, external services, test doubles) is an architect decision; ACs like "tests connect to the DB directly" get flagged back to the architect when unsanctioned. When integration tests are warranted, the tester reuses the project's existing constructors, factories, fixtures, and client/repo code as-is — never a new DB connection or setup helper when one already exists. The tester writes the red tests for **batch 1**, commits red, hands off in one message, and idles. The coder works batch 1 continuously — smallest diff to green each failing test, iterate to the next, refactor only once every targeted test in the batch is green — and reports green. The tester then writes batch 2's red tests informed by what batch 1 revealed about the code shape, hands off, and the loop repeats until every AC has a green batch. This checkpointing keeps later batches honest if earlier ones expose shape changes; it does not reintroduce per-AC ping-pong within a batch. Skip tests and lint for non-behavioral changes like config or docs.

When every batch is green and refactored, the tester runs lint on changed files (first match from project script — `lint` in package.json, `lint` target in Taskfile, linter config in pyproject.toml — then language default: ESLint for JS/TS, ruff for Python, golangci-lint for Go), re-runs the full project test suite (not just new tests), and updates the task file's `Key Files` to match the files actually changed. Lint errors count as failing tests — coder fixes, tester re-checks. The tester then reports `batches green, lint clean, suite green, key files reconciled` to the coordinator and idles.

The coordinator owns the third-party spec-vs-code validation pass — not the tester. On the tester's clean report, the coordinator spawns a one-shot validator via the `Agent` tool (subagent_type `general-purpose`), handing it only the epic's spec path, the task path, and the git diff range against the task's `Base` branch. The validator has no test-writing history and no team membership; cold context is what makes it third-party, and coordinator-level spawn keeps it from being implicitly biased by the tester's "I think this is done." The validator reads spec and diff side by side and returns a JSON report `{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}], "drift": [{"clause": "...", "reason": "..."}]}`. The coordinator parses the report: empty `drift` → task approved; any drift → message routed back to the tester with the drift list, tester re-engages the coder per the escalation protocol, the loop repeats until drift is empty. The validator never sees the tester's or coder's conversation.

On approval, bulk-update the task: mark every AC `[x]` in the task file, flip plan.md Status (Todo -> In Progress -> Done), then stage only the files that implement the task and STOP — tell the user to run `/commit` themselves. Never invoke `/commit` via Skill on the user's behalf. The user reads the staged diff and commits.

Tester and coder responses to the coordinator are status + changed file paths + blockers only. No code blocks, no test output dumps, no spec-clause citations echoed back. Spec-vs-code citations stay inside the tester's context; the coordinator receives `approved` or a blocker list referencing AC or spec-clause identifiers. Keep reports under ~15 lines so the main thread stays cold and compaction-resistant.

## Mid-Flight Revision

If review feedback is a requirement change — not a code tweak but a shift in what to build — pause tester and coder (no partial commits; leave the tree or stash) and invoke `/sdlc-design` scoped to the change. The design team re-spawns, reads the current manifest and in-flight work, and decides per remaining task: keep, revise, or void. Once the user confirms the updated plan, the implement team resumes on the current or revised task.

## Abandon Task

Distinct from a requirements shift: when implementation reveals the task as written cannot be built — wrong decomposition, missing dependency surfaced mid-build, contract incompatible with predecessor — the coder reports `unbuildable: <reason>` to the tester, the tester confirms (or downgrades to a fixable blocker), and on confirmation the team pauses and invokes `/sdlc-design` for void-or-revise. The architect either voids the task (mark `[voided: <reason>]` in MANIFEST, leave the file) or revises it (mark `[revised: vN]`, overwrite the file). Stash any work-in-progress before the design session; do not commit a partial green. Resume implementation only after the user confirms the revised plan.

## Team Teardown

Once the task's PR is opened and the manifest is updated, shut down the team. Send `SendMessage` to `sdlc-tester` and `sdlc-coder` with `{type: "shutdown_request", reason: "Task complete."}`, wait for every `shutdown_approved` response, then call `TeamDelete` to remove the team and task directories. Do not skip teardown — leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-task (e.g., user stops mid-AC), leave the team running to preserve test and code context; teardown happens only at task completion or when the user explicitly ends the session.

## Completion

Once all criteria are complete, STOP and tell the user to run `/pr` themselves, noting the task's `Base` field as the target branch. Never invoke `/pr` via Skill on the user's behalf. Once the user provides the PR URL, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Update the manifest's status to "In Progress (N/M tasks done)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task from any epic. Only suggest `/sdlc-complete <project-dir>` when every epic in the manifest is marked Complete — never offer to complete an individual epic.

<!-- response-style:v1 — keep this block byte-identical across all skills; verify with `task verify:response-style`. -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

NEVER implement code directly in the main conversation — all implementation MUST happen through the tester-coder team via TeamCreate. Always follow the TDD loop: failing tests before code, refactor only once green. Test through public interfaces. Never weaken a test to get it green. Never mark a task complete while any spec clause is unaccounted for. Never stage with `git add .` or `git add -A`. NEVER run `git commit`, `git push`, `gh pr create`, or `gh pr edit` directly, and NEVER invoke `/commit` or `/pr` via Skill — the user runs those themselves. Stage files and hand off; don't execute. Always assign PRs to the current user. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
