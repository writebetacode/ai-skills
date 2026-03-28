---
name: pr
description: Create or update a pull request with a human-readable title and structured description. Use when the user wants to open or update a PR for the current branch.
model: sonnet
---

# PR: Create or Update Pull Request

## Workflow

1. **Prerequisites**: Run `gh auth status` — stop if not installed or not logged in.
2. **Context**: Run in parallel:
   - `git branch --show-current`
   - `git remote get-url origin`
   - `gh api user --jq '.login'`
   - `git status --short`
   - `gh pr list --head $(git branch --show-current) --json number,title,baseRefName`
   Warn if uncommitted changes. Update mode if PR exists, create mode if not.
3. **Base branch**: Use branch from `$ARGUMENTS` if provided, else auto-detect closest ancestor branch (fewest commits from HEAD), fall back to main. Confirm.
4. **Ticket**: Parse branch name, validate with `gh issue view <ticket> --json title`. Use N/A if invalid.
5. **Title**: Human-readable, under 70 chars, no commit prefixes, summarizes combined effect.
6. **Body**:
   - **Tickets**: link to issue or N/A
   - **Summary**: 2-4 sentences, what and why
   - **Why**: value and intent, not implementation details
   - **Changes**: grouped by category (Domain, Tests, Config, etc.)
   - **Breaking Changes**: only if applicable
   - **Dependencies**: only if applicable
7. **Confirm**: Show title, base, and body. Ask before pushing (if needed) and before creating/updating.
8. **Execute**: `gh pr create --assignee @me` or `gh pr edit`. Add `--draft` if "draft" in `$ARGUMENTS`. Show PR URL.

## Rules

- Always `--assignee @me`
- Never push or create/update without user confirmation
- No broken ticket links — validate before use
- NEVER add Co-Authored-By or any AI attribution lines to commit messages — ASCII only
- No "Test Plan" section in the PR body — use only the sections listed above

## User Input

$ARGUMENTS
