---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after /sdlc-design to implement tasks one at a time with a tester-coder agent team and built-in revision handling.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: design -> **[implement]** -> complete

Resolve the task from: direct path, task number, plan directory, or prompt user.

## Workflow

Start by loading the task file, plan, and specification from the plan directory, along with project context files (CLAUDE.md, .cursorrules, AGENTS.md, docs/architecture/ if present) and predecessor task files. Read the `MANIFEST.md` from the project root and upstream epic specs listed as dependencies to understand interfaces this epic consumes.

Set up the development branch by either checking out an existing local branch (and `git pull`) or creating a new one from the Base field, falling back to `main` for squash-merged stacks. Assess progress by reading `[x]` markers and report: fresh start, resuming, or complete.

Spin up an agent team with model `inherit` to implement acceptance criteria. The **tester** writes a failing test for the current AC (RED). Once the test is in place, the **coder** writes the minimum code to make it pass (GREEN), then refactors while keeping tests green (REFACTOR). The tester confirms all tests pass after refactoring. Skip tests for non-behavioral changes like config or docs. After each AC, present the changes to the user for review before committing. The user may ask questions, request adjustments, or approve. Once approved, lint and stage specific files, then run `/commit` to create the commit. After each commit, mark `[x]` in the task file and update plan.md Status (Todo -> In Progress -> Done).

## Revision Handling

If the user's feedback during review amounts to a requirement change -- not just a code tweak but a shift in what should be built -- pause the tester and coder and invoke `/sdlc-design` scoped to the change so the full agent team (researcher, architect, spec-creator, validator) can evaluate the impact, update specs, plans, and verify cross-epic consistency. Resume the tester and coder with the revised ACs once the user confirms the updated plan.

## Completion

Once all criteria are complete, run `/pr` to create or update the pull request, using the task's Base field as the target branch. Immediately after the PR is created, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Update the manifest's status to "In Progress (N/M tasks done)" after each task, or "Complete" when the final task is done. When completing the last task of an epic, report which downstream epics are now fully unblocked. Show the PR URL and suggest the next actionable task from any epic. Only suggest `/sdlc-complete <project-dir>` when every epic in the manifest is marked Complete -- never offer to complete an individual epic.

## Rules

Always follow the TDD loop -- failing tests before code, refactor only once green. Test through public interfaces. Never stage with `git add .` or `git add -A`. Never commit, push, or create a PR without user confirmation -- `/commit` and `/pr` handle their own confirmation. Always present changes for user review after each AC before committing. Always assign PRs to the current user. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
