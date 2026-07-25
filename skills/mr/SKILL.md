---
name: mr
description: Create or update a GitLab merge request with a human-readable title and structured description. Use when the user wants to open or update an MR for the current branch on GitLab.
model: sonnet
---

# MR

## Workflow

Verify `glab auth status`; stop on failure. Gather in parallel: current branch, remote URL, current username via `glab api user --jq .username`, MR status. Warn on uncommitted changes. Resolve target branch from arguments, or auto-detect by matching branch-name prefix against other local branches, falling back to `git merge-base` against `main`. Draft a human-readable title under 70 characters covering combined changes. Compose the description from the template, then create with `glab mr create --yes --assignee <username> --target-branch <base> --title <title> --description <body>` (add `--draft` if "draft" appears in `$ARGUMENTS`), or update an existing MR with `glab mr update <branch> --description <body>`. Display the MR URL.

Jira ticket references are informational only — GitLab does not close Jira issues on merge, so never use closing keywords (`Closes`, `Fixes`, `Resolves`) for a Jira key.

## MR Body Template

<!-- pr-body:v1 -->
Use this exact markdown structure. Omit Breaking Changes and Dependencies when not applicable.

```markdown
## Tickets
[#<number>](<url>) — <title>, or N/A

## Summary
<2-4 sentences: what changed and why.>

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

Always assign to the current user by resolved username — `glab` has no `@me` equivalent, so resolve it via `glab api user` rather than hardcoding. Always pass `--yes` on create; without it `glab` blocks on an interactive confirmation prompt. Never apply a closing keyword to a Jira key. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Title violation:** any title that is not a plain-English, human-readable sentence — raw branch names, ticket slugs, kebab-case, or machine-style identifiers must be rewritten before create/update. `fix/auth-token-refresh` or `PROJ-123` are violations; "Fix authentication token refresh on expired sessions" is acceptable.

**Body violation:** any body off the exact template — Tickets, Summary, Why, and Changes in that order using the prescribed markdown. Freeform prose, generic layouts, or invented sections like "Test Plan" must be corrected before create/update.

## User Input

$ARGUMENTS
