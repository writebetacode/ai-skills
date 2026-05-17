---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits, PRs, TDD, and third-party validation via a tester-coder agent team. Use after /sdlc-design to implement tasks one at a time.
model: opus
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: design -> **[implement]** -> complete

## Task Resolution

Resolve from direct path, task number, or plan directory. With no arguments or only a project path: read `MANIFEST.md`, walk Build Order to the first epic whose status is not "Complete", read that epic's `plan.md`, find the first task whose ACs are not all `[x]`, use it. If no incomplete task remains, advance to the next epic in build order.

Before resolving a task in any epic, validate preconditions: every epic listed under that epic's `spec.md` `## Dependencies` must be `Complete` in MANIFEST. If a dependency is not Complete, refuse to start — name the missing dependency and tell the user to finish it first or invoke `/sdlc-design` to revise the graph. Mirrors the design-time stack-linearity gate.

## Agent Team

Implementation MUST happen through a team via TeamCreate named `sdlc-implement-<project-slug>`. Spawn two permanent agents via `Agent`: `sdlc-tester` (opus) and `sdlc-coder` (opus). Each agent's AGENT.md carries its workflow and identity — do not re-specify here. Never implement code directly in the main conversation.

## Workflow

**Coordinator reads.** Only `MANIFEST.md` and the task file. Do not read spec, plan, ADRs, architecture docs, CLAUDE.md, .cursorrules, AGENTS.md, upstream epic specs, or predecessor tasks in the main thread — the tester and coder AGENT.md files own that reading list, and the coordinator stays a thin dispatcher to keep compaction at bay.

**Branch setup.** Check out the existing local branch (and `git pull`) or create a new one from the task's `Base` field, falling back to `main` for squash-merged stacks. Assess progress via `[x]` markers and report: fresh start, resuming, or complete.

**Handoff.** Read the task file header for an optional architect-set `Depth: ultrathink` marker. Hand each agent the task path plus the project root; they load their own context. When `Depth: ultrathink` is set, prepend `ultrathink — ` to the handoff message to both agents.

**Batched TDD loop.** Tester groups ACs into cohesive batches (one batch per AC for small tasks, or related ACs grouped when they share fixtures or shape). Table-driven unit tests by default; integration tests only when spec or architecture brief prescribes them. Integration strategy is an architect decision — ACs like "tests connect to the DB directly" get flagged back to the architect when unsanctioned. When integration is warranted, the tester reuses the project's existing constructors, factories, fixtures, and client/repo code as-is — never a new DB connection or setup helper when one already exists. Tester writes red tests for **batch 1**, commits red, hands off in one message, idles. Coder works batch 1 continuously — smallest diff to green each failing test, iterate, refactor only once every targeted test is green — and reports green. Tester then writes batch 2's red tests informed by what batch 1 revealed, hands off, loop repeats until every AC has a green batch. This checkpointing keeps later batches honest if earlier ones expose shape changes; it does not reintroduce per-AC ping-pong within a batch. Skip tests and lint for non-behavioral changes (config, docs).

**End of batches.** Tester runs lint on changed files (first match from project script — `lint` in package.json, `lint` target in Taskfile, linter config in pyproject.toml — then language default: ESLint for JS/TS, ruff for Python, golangci-lint for Go), re-runs the full project suite, and updates the task file's `Key Files` to match files actually changed. Lint errors count as failing tests — coder fixes, tester re-checks. Tester reports `batches green, lint clean, suite green, key files reconciled` and idles.

**Third-party validation (coordinator-owned).** On the tester's clean report, the coordinator spawns a one-shot validator via the `Agent` tool (subagent_type `general-purpose`), handing it only the epic's spec path, the task path, and the git diff range against the task's `Base` branch. The validator has no test-writing history and no team membership; cold context is what makes it third-party, and coordinator-level spawn keeps it from being implicitly biased by the tester's "I think this is done." The validator reads spec and diff side by side and returns JSON: `{"satisfied": [{"clause": "FR-1", "files": ["path:line"]}], "drift": [{"clause": "...", "reason": "..."}]}`. Parse: empty `drift` → approved; any drift → route back to the tester with the drift list, tester re-engages the coder per the escalation protocol, loop until drift is empty. The validator never sees the tester's or coder's conversation.

**On approval.** Mark every AC `[x]` in the task file, flip plan.md Status (Todo -> In Progress -> Done), stage only the files that implement the task, and STOP — tell the user to run `/commit` themselves. Never invoke `/commit` via Skill on the user's behalf. The user reads the staged diff and commits.

**Agent reports.** Status + changed file paths + blockers only. No code blocks, no test output, no spec-clause citations. Spec-vs-code citations stay inside the tester's context; the coordinator receives `approved` or a blocker list referencing AC or spec-clause identifiers. Under ~15 lines per report so the main thread stays cold.

## Mid-Flight Revision

If review feedback is a requirement change — not a code tweak but a shift in what to build — pause tester and coder (no partial commits; leave the tree or stash) and invoke `/sdlc-design` scoped to the change. Design team re-spawns, reads manifest and in-flight work, decides per remaining task: keep, revise, or void. Once the user confirms, the implement team resumes on the current or revised task.

## Abandon Task

Distinct from a requirements shift: when implementation reveals the task as written cannot be built — wrong decomposition, missing dependency surfaced mid-build, contract incompatible with predecessor — the coder reports `unbuildable: <reason>` to the tester, the tester confirms (or downgrades to a fixable blocker), and on confirmation the team pauses and invokes `/sdlc-design` for void-or-revise. Architect either voids (mark `[voided: <reason>]` in MANIFEST, leave the file) or revises (mark `[revised: vN]`, overwrite). Stash any WIP before the design session; do not commit a partial green. Resume only after the user confirms the revised plan.

## Team Teardown

Once the PR is opened and the manifest is updated, shut down the team. Send `SendMessage` to `sdlc-tester` and `sdlc-coder` with `{type: "shutdown_request", reason: "Task complete."}`, wait for every `shutdown_approved`, then call `TeamDelete`. Do not skip teardown — leaving agents running leaks context and keeps the team directory on disk.

If the session pauses mid-task, leave the team running to preserve test and code context; teardown happens only at task completion or when the user explicitly ends the session.

## Completion

Once all criteria are complete, STOP and tell the user to run `/pr` themselves, noting the task's `Base` field as the target branch. Never invoke `/pr` via Skill. Once the user provides the PR URL, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Update the manifest status to "In Progress (N/M tasks done)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task. Only suggest `/sdlc-complete <project-dir>` when every epic is Complete — never offer to complete an individual epic.

<!-- response-style:v1 — keep this block byte-identical across all skills; verify with `task verify:response-style`. -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

NEVER implement code directly in the main conversation — all implementation through the tester-coder team via TeamCreate. Always follow the TDD loop: failing tests before code, refactor only once green. Test through public interfaces. Never weaken a test to get it green. Never mark a task complete while any spec clause is unaccounted for. Never stage with `git add .` or `git add -A`. NEVER run `git commit`, `git push`, `gh pr create`, or `gh pr edit` directly, and NEVER invoke `/commit` or `/pr` via Skill — the user runs those. Stage files and hand off; don't execute. Always assign PRs to the current user. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
