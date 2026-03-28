---
name: pr
description: Create or update a pull request with a human-readable title and structured description. Use when the user wants to open or update a PR for the current branch.
model: sonnet
---

# PR: Create or Update Pull Request

## Workflow

Verify that the user is authenticated with `gh auth status` and stop if they are not. Gather context in parallel by checking the current branch, remote URL, user login, and PR status; warn the user if there are uncommitted changes. Use the base branch provided in the arguments or auto-detect the closest ancestor branch, falling back to main if necessary, and confirm this choice with the user. Validate any ticket numbers in the branch name using `gh issue view` and prepare a human-readable title under 70 characters that summarizes the combined changes. Compose the PR body using the sections below. Show the title, base, and body to the user, asking for confirmation before pushing code or creating/updating the PR. Finally, execute the command using `gh pr create --assignee @me` or `gh pr edit`, adding `--draft` if "draft" is in `$ARGUMENTS`, and display the resulting PR URL.

## PR Body Sections

- **Tickets**: link to issue or N/A
- **Summary**: 2-4 sentences, what and why
- **Why**: value and intent, not implementation details
- **Changes**: grouped by category (Domain, Tests, Config, etc.)
- **Breaking Changes**: only if applicable
- **Dependencies**: only if applicable

## Rules

Always assign the PR to the current user and never push or create/update a PR without explicit user confirmation. Validate all ticket links before use and never add AI attribution or "Co-Authored-By" lines to any messages. Do not include a "Test Plan" section in the PR body; use only the authorized sections for tickets, summary, why, changes, breaking changes, and dependencies.

## User Input

$ARGUMENTS
