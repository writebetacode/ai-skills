---
name: pr
description: Create or update a pull request with a human-readable title and structured description. Use when the user wants to open or update a PR for the current branch.
model: sonnet
---

# PR

## Workflow

Verify `gh auth status`; stop on failure. Gather in parallel: current branch, remote URL, user login, PR status. Warn on uncommitted changes. Resolve base from arguments, or auto-detect by matching branch-name prefix against other local branches, falling back to `git merge-base` against `main`. Validate ticket numbers via `gh issue view`. Draft a human-readable title under 70 characters covering combined changes. Compose body from the template, run `gh pr create --assignee @me --base <base>` or `gh pr edit --base <base>` (add `--draft` if "draft" appears in `$ARGUMENTS`), display the PR URL.

## PR Body Template

<!-- pr-body:v1 -->
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

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Always assign to @me with `--assignee @me`. Never reference a ticket without validating it via `gh issue view` first. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

**Title violation:** any title that is not a plain-English, human-readable sentence — raw branch names, ticket slugs, kebab-case, or machine-style identifiers must be rewritten before create/update. `fix/auth-token-refresh` or `PROJ-123` are violations; "Fix authentication token refresh on expired sessions" is acceptable.

**Body violation:** any body off the exact template — Tickets, Summary, Why, and Changes in that order using the prescribed markdown. Freeform prose, generic layouts, or invented sections like "Test Plan" must be corrected before create/update.

## User Input

$ARGUMENTS
