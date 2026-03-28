---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after sdlc-validate to implement tasks one at a time with a full test-commit-PR inner loop.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: brainstorm → plan → validate → **[implement]** → complete

Resolve the task from: direct path, task number, plan directory, or prompt user.

## Implementation Mode

1. **Read context**: Load the task file, index.md, and spec.md (all in the same `plans/YYYY-MM-DD-<slug>/` directory), plus CLAUDE.md/.cursorrules/AGENTS.md, docs/architecture.md, and predecessor task files in a single turn.
2. **Branch setup**: Extract Branch/Base from task file. If the branch exists locally, check it out and run `git pull` to sync. If it does not exist, resolve the base: if Base branch exists use it, otherwise fall back to `main` (handles squash-merged stacked bases). Create the branch from the resolved base. Confirm active branch.
3. **Progress check**: Read `[x]` markers on acceptance criteria. Report: fresh start, resuming, or complete.
4. **TDD loop** — one criterion at a time:
   - **RED**: Write one failing test via public interfaces only.
   - **GREEN**: Write minimum code to pass.
   - **REFACTOR**: Clean up once green. Never while red.
   - Skip test for non-behavioral changes (config, wiring, docs).

   Then: run linter, fix issues. Stage specific files (never `git add .` or `git add -A`). Conventional commit (`<type>: <desc>`, under 72 chars, imperative, no Co-Authored-By or AI attribution). Ask `Commit? (yes/no/edit)` — on edit, show message, accept correction, re-confirm. Commit via HEREDOC on yes. **Immediately after committing**: mark criterion `[x]` in the task file and update index.md Status (Todo → In Progress → Done). Continue if criteria remain.

5. **PR**: Run `gh auth status` — stop if not installed or not logged in. Check `gh pr list --head <branch> --json number,title,baseRefName` — update mode if PR exists, create mode if not. Push `git push -u origin <branch>`. Build human-readable title (under 70 chars, no commit prefixes). Body: **Tickets** (parse from branch name, validate with `gh issue view`, use N/A if invalid) | **Summary** (2-4 sentences, what and why) | **Why** (value and intent, not implementation details) | **Changes** (grouped by category: Domain, Tests, Config, etc.) | **Breaking Changes** (only if applicable) | **Dependencies** (only if applicable). Show title, base, and body. Ask "Draft PR?" and "Add a reviewer? (username or skip)". Ask before creating/updating. `gh pr create --base <base> --assignee @me` (with `--draft`/`--reviewer` as needed) or `gh pr edit`. **Immediately after the PR is created/updated**: capture the PR URL and number, then write `## PR\n\n[#<number>](<url>)` to the bottom of the task file (do not commit this change). Show PR URL. Suggest next task or `sdlc-complete <plan-dir>` if last.

## Rules

- One test at a time — red, green, refactor, never skip ahead
- Never refactor while red
- Tests through public interfaces only
- Stage specific files — never `git add .` or `git add -A`
- Conventional commits, imperative mood
- Never commit or push without user confirmation
- Always `--assignee @me`
- No broken ticket links — validate before use
- No "Test Plan" section in the PR body — use only: Tickets, Summary, Why, Changes, Breaking Changes, Dependencies
- NEVER add Co-Authored-By or any AI attribution lines to commit messages — ASCII only
