---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after /sdlc:validate to implement tasks one at a time with a full test-commit-PR inner loop.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: brainstorm → plan → validate → **[implement]** → complete

Resolve the task from: direct path, task number, plan directory, or prompt user.

## Workflow

Start by loading the task file, index, and specification from the plan directory, along with project context files (CLAUDE.md, .cursorrules, AGENTS.md, docs/architecture.md if present) and predecessor task files. Set up the development branch by either checking out an existing local branch (and `git pull`) or creating a new one from the Base field, falling back to `main` for squash-merged stacks. Assess progress by reading `[x]` markers and report: fresh start, resuming, or complete.

Enter a TDD loop for each acceptance criterion: write one failing test (RED), add minimum code to pass (GREEN), then clean up once green (REFACTOR) — skip tests for non-behavioral changes like config or docs. Lint and stage specific files, then run `/commit` to create the commit. After each commit, mark `[x]` in the task file and update index.md Status (Todo → In Progress → Done).

Once all criteria are complete, run `/pr` to create or update the pull request, using the task's Base field as the target branch. Immediately after the PR is created, write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Show the PR URL and suggest the next task or `/sdlc:complete <plan-dir>` if this is the last one.

## Rules

Always follow the TDD loop by writing failing tests before code and only refactor once the tests pass. Ensure all tests interact through public interfaces and never stage files using broad commands like `git add .` or `git add -A`. Never commit, push, or create a pull request without receiving explicit user confirmation first — the `/commit` and `/pr` skills handle confirmation, so do not duplicate those prompts. Always assign pull requests to the current user.

## User Input

$ARGUMENTS
