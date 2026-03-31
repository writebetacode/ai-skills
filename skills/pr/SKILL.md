---
name: pr
description: Create or update a pull request with a human-readable title and structured description. Use when the user wants to open or update a PR for the current branch.
---

# PR: Create or Update Pull Request

## Workflow

Verify that the user is authenticated with `gh auth status` and stop if they are not. Gather context in parallel by checking the current branch, remote URL, user login, and PR status; warn the user if there are uncommitted changes. Use the base branch provided in the arguments, or auto-detect by checking whether the branch name contains a prefix matching another local branch and falling back to `git merge-base` against `main` when no naming match is found. Validate any ticket numbers in the branch name using `gh issue view` and prepare a human-readable title under 70 characters that summarizes the combined changes. Compose the PR body using the sections below and execute the command using `gh pr create --assignee @me` or `gh pr edit`, adding `--draft` if "draft" is in `$ARGUMENTS`, and display the resulting PR URL.

## PR Body Template

Use this exact markdown structure for the PR body. Omit Breaking Changes and Dependencies when not applicable.

```markdown
## Tickets
[#<number>](<url>) — <title>, or N/A

## Summary
<2–4 sentences: what changed and why.>

## Why
<The value this delivers and the intent behind it, without detailing implementation mechanics.>

## Changes

**<Category>**
- `<file>`: <summary of change>
- `<file>`: <summary of change>

**<Category>**
- `<file>`: <summary of change>

## Breaking Changes

<Describe any breaking changes, or omit this section entirely.>

## Dependencies

<List added, removed, or upgraded dependencies, or omit this section entirely.>
```

## Rules

Always assign the PR to @me. Validate all ticket links before use. Do not include a "Test Plan" section in the PR body; use only the authorized sections for tickets, summary, why, changes, breaking changes, and dependencies. Use only ASCII characters and never include AI attribution or "Co-Authored-By" lines in any output.

## User Input

$ARGUMENTS
