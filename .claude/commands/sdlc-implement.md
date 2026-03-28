---
name: sdlc-implement
description: Execute a task from an implementation plan with integrated commits and PRs. Use after /sdlc:validate to implement tasks one at a time with a full test-commit-PR inner loop.
---

# Implement: Execute Plan with Integrated Commits and PRs

Flow: brainstorm → plan → validate → **[implement]** → complete

Resolve the task from: direct path, task number, plan directory, or prompt user.

## Workflow

1. **Read context**: Load the task file, index.md, and spec.md from `plans/YYYY-MM-DD-<slug>/`, plus CLAUDE.md/.cursorrules/AGENTS.md, docs/architecture.md, and predecessor task files.
2. **Branch setup**: Extract Branch/Base from the task file. If the branch exists locally, check it out and `git pull`. If not, use Base if it exists, otherwise fall back to `main` (squash-merged stack). Create the branch. Confirm active branch.
3. **Progress check**: Read `[x]` markers. Report: fresh start, resuming, or complete.
4. **TDD loop** — repeat per criterion:
   - RED: one failing test via public interface only.
   - GREEN: minimum code to pass.
   - REFACTOR: clean up once green, never while red.
   - Skip test for non-behavioral changes (config, wiring, docs).
   - Lint, stage specific files, commit via HEREDOC (`<type>: <desc>`, under 72 chars, no Co-Authored-By). Ask `Commit? (yes/no/edit)`.
   - After commit: mark `[x]` in the task file and update index.md Status (Todo → In Progress → Done).
5. **PR**:
   - Check `gh auth status` — stop if not ready.
   - Check for existing PR: `gh pr list --head <branch> --json number,title,baseRefName`. Push `git push -u origin <branch>`.
   - Build title (under 70 chars, no commit prefixes). Body: **Tickets** (parse branch name, validate with `gh issue view`, N/A if invalid) | **Summary** | **Why** | **Changes** | **Breaking Changes** (if any) | **Dependencies** (if any).
   - Ask "Draft PR?" and "Add a reviewer? (username or skip)". Confirm before creating/updating.
   - `gh pr create --base <base> --assignee @me` (with `--draft`/`--reviewer` as needed) or `gh pr edit`.
   - Immediately after: write `## PR\n\n[#<number>](<url>)` to the task file (do not commit). Show PR URL.
   - Suggest next task or `/sdlc:complete <plan-dir>` if last.

## Rules

- One test at a time — red, green, refactor, never skip ahead
- Never refactor while red; tests through public interfaces only
- Stage specific files only — never `git add .` or `git add -A`
- Never commit, push, or create/update a PR without user confirmation
- No broken ticket links — validate with `gh issue view` before use
- No "Test Plan" section — body uses only: Tickets, Summary, Why, Changes, Breaking Changes, Dependencies
- Always `--assignee @me`; NEVER add Co-Authored-By or AI attribution to commits

## User Input

$ARGUMENTS
