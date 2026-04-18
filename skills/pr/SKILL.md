---
name: pr
description: Create or update a pull request with a human-readable title and structured description. Use when the user wants to open or update a PR for the current branch.
---

# PR: Create or Update Pull Request

## Workflow

Verify authentication with `gh auth status` and stop if it fails. Gather context in parallel — current branch, remote URL, user login, PR status — and warn if there are uncommitted changes. Use the base branch from arguments, or auto-detect by matching the branch name prefix against other local branches and falling back to `git merge-base` against `main`. Validate any ticket numbers in the branch name with `gh issue view`, then prepare a human-readable title under 70 characters that summarizes the combined changes. Compose the PR body using the template below, then run `gh pr create --assignee @me` or `gh pr edit`, adding `--draft` if "draft" appears in `$ARGUMENTS`, and display the resulting PR URL.

## PR Body Template

Use this exact markdown structure. Omit Breaking Changes and Dependencies when not applicable.

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

Always assign the PR to @me. Validate all ticket links before use. Do not include a "Test Plan" section; only the authorized sections (Tickets, Summary, Why, Changes, Breaking Changes, Dependencies) are permitted. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

It is a violation to use a PR title that is not a plain-English, human-readable sentence. Raw branch names, ticket slugs, kebab-case strings, or any machine-style identifier must be rewritten into a natural-language summary before the PR is created or updated. For example, `fix/auth-token-refresh` or `PROJ-123` are violations; "Fix authentication token refresh on expired sessions" is acceptable.

It is a violation to produce a PR body that does not follow the exact template. The body must contain Tickets, Summary, Why, and Changes in that order using the prescribed markdown structure. Freeform prose, generic layouts, or invented sections like "Test Plan" are violations and must be corrected before the PR is created or updated.

## User Input

$ARGUMENTS
