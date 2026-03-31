---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after /sdlc-design to implement tasks one at a time with a tester-coder-reviewer agent team and built-in revision handling.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: design -> **[implement]** -> complete

Resolve the task from: direct path, task number, or plan directory. When called with no arguments or only a project path, read the project's `MANIFEST.md` and walk the Build Order to find the first epic whose status is not "Complete". Then read that epic's `plan.md`, find the first task whose acceptance criteria are not all marked `[x]`, and use it. If no incomplete task remains in that epic, advance to the next epic in build order.

## Workflow

Start by loading the task file, plan, and specification from the plan directory, along with project context files (CLAUDE.md, .cursorrules, AGENTS.md, docs/architecture/ if present) and predecessor task files. Read the `MANIFEST.md` from the project root and upstream epic specs listed as dependencies to understand interfaces this epic consumes.

Set up the development branch by either checking out an existing local branch (and `git pull`) or creating a new one from the Base field, falling back to `main` for squash-merged stacks. Assess progress by reading `[x]` markers and report: fresh start, resuming, or complete.

MUST spin up an agent team using the TeamCreate tool with model `inherit` to implement acceptance criteria — never implement code directly in the main conversation. All implementation work happens through the team's agents. The **tester** writes a failing test for the current AC (RED). Once the test is in place, the **coder** writes the minimum code to make it pass (GREEN), then refactors while keeping tests green (REFACTOR). The tester confirms all tests pass after refactoring, then runs linting on the changed files using the first match from this resolution order:

1. Project script (`lint` in package.json, `lint` target in Taskfile, linter config in pyproject.toml)
2. Language-default linter (ESLint for JS/TS, ruff for Python, golangci-lint for Go)

Lint errors are treated like failing tests: the coder fixes them and the tester re-checks before moving on. Once tests and lint are green, the **reviewer** inspects the changes for code quality and idiomatic patterns (naming, DRY, unnecessary complexity), spec and AC alignment (does the implementation actually satisfy the criteria and match the spec's intent), and security and correctness (OWASP-style checks, edge cases, error handling gaps). Review issues go back to the coder, who fixes them; the tester and reviewer both re-validate before the AC is presented for user review. Skip tests, linting, and review for non-behavioral changes like config or docs. After each AC, present the changes to the user for review before committing. The user may ask questions, request adjustments, or approve. Once approved, lint and stage specific files, then invoke the `/commit` skill via the Skill tool to create the commit. After each commit, mark `[x]` in the task file and update plan.md Status (Todo -> In Progress -> Done).

## Revision Handling

If the user's feedback during review amounts to a requirement change -- not just a code tweak but a shift in what should be built -- pause the tester, coder, and reviewer and invoke `/sdlc-design` scoped to the change so the full agent team (researcher, architect, spec-creator, validator) can evaluate the impact, update specs, plans, and verify cross-epic consistency. Resume the tester, coder, and reviewer with the revised ACs once the user confirms the updated plan.

## Completion

Once all criteria are complete, invoke the `/pr` skill via the Skill tool to create or update the pull request, using the task's Base field as the target branch. Immediately after the PR is created, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Update the manifest's status to "In Progress (N/M tasks done)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task from any epic. Only suggest `/sdlc-complete <project-dir>` when every epic in the manifest is marked Complete -- never offer to complete an individual epic.

## Rules

NEVER implement code directly in the main conversation — all implementation MUST happen through a tester-coder-reviewer agent team created via TeamCreate. Implementing without the team is a violation. Always follow the TDD loop -- failing tests before code, refactor only once green. Test through public interfaces. Never stage with `git add .` or `git add -A`. NEVER run `git commit`, `git push`, `gh pr create`, or `gh pr edit` directly — these operations MUST go through the `/commit` and `/pr` skills via the Skill tool. Any commit or PR created outside of these skills is a violation. The skills handle their own user confirmation, staging verification, and formatting. Always present changes for user review after each AC before committing. Always assign PRs to the current user. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
