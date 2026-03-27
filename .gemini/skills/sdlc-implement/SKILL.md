---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after sdlc-validate to implement tasks one at a time with a full test-commit-PR inner loop.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: brainstorm → plan → validate → **[implement]**

If the user's request starts with "complete", skip to **Complete Mode**. Otherwise resolve the task from: direct path, task number, plan directory, or prompt user.

## Implementation Mode

1. **Read context**: Load the task file, index.md, source spec, CLAUDE.md/.cursorrules/AGENTS.md, docs/architecture.md, and predecessor task files in a single turn.
2. **Branch setup**: Extract Branch/Base from task file. Check out if exists, create from base if not. Confirm active branch.
3. **Progress check**: Read `[x]` markers on acceptance criteria. Report: fresh start, resuming, or complete.
4. **TDD loop** — one criterion at a time:
   - **RED**: Write one failing test via public interfaces only.
   - **GREEN**: Write minimum code to pass.
   - **REFACTOR**: Clean up once green. Never while red.
   - Skip test for non-behavioral changes (config, wiring, docs).

   Then: run linter, fix issues. Stage specific files (never `git add .` or `git add -A`). Conventional commit (`<type>: <desc>`, under 72 chars, imperative). Ask `Commit? (yes/no/edit)` — on edit, show message, accept correction, re-confirm. Commit via HEREDOC on yes. Mark criterion `[x]` and update index.md Status (Todo → In Progress → Done) locally. Continue if criteria remain.

5. **PR**: Run `gh auth status` — stop if not installed or not logged in. Check `gh pr list --head <branch> --json number,title,baseRefName` — update mode if PR exists, create mode if not. Push `git push -u origin <branch>`. Build human-readable title (under 70 chars, no commit prefixes). Body: **Tickets** (parse from branch name, validate with `gh issue view`, use N/A if invalid) | **Summary** (2-4 sentences, what and why) | **Why** (value and intent, not implementation details) | **Changes** (grouped by category: Domain, Tests, Config, etc.) | **Breaking Changes** (only if applicable) | **Dependencies** (only if applicable). Show title, base, and body. Ask "Draft PR?" and "Add a reviewer? (username or skip)". Ask before creating/updating. `gh pr create --base <base> --assignee @me` (with `--draft`/`--reviewer` as needed) or `gh pr edit`. Capture the PR URL and number. Add `## PR\n\n[#<number>](<url>)` to the task file (do not commit it). Show PR URL. Suggest next task or `sdlc-implement complete <plan-dir>` if last.

## Complete Mode

Resolve plan directory. Verify all tasks are "Done" in index.md (warn if not, ask to proceed anyway). After confirmation: move plan directory and its spec to `plans/complete/YYYY-MM-DD-<slug>/`, remove empty implementation directory, report what was archived.

## Rules

- One test at a time — red, green, refactor, never skip ahead
- Never refactor while red
- Tests through public interfaces only
- Stage specific files — never `git add .` or `git add -A`
- Conventional commits, imperative mood
- Never commit or push without user confirmation
- Always `--assignee @me`
- No broken ticket links — validate before use
- ASCII only, no AI attribution
