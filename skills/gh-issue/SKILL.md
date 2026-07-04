---
name: gh-issue
description: Create a consistently-formatted GitHub issue in the current repo. Use when filing a bug, feature request, chore, or question.
model: sonnet
---

# GH Issue

## Workflow

Verify `gh auth status` and repo name; stop on failure. Parse arguments for a title, then prompt for missing fields: type, title, description, priority, and optional sections (repro steps, acceptance criteria). Build the body from the template, omitting skipped sections. Show formatted title and body, get confirmation or edits. On confirmation, create via `gh issue create --assignee @me` and display the URL.

## Issue Body Template

```
## Type
<type>

## Description
<description>

## Priority
<low | medium | high>

## Steps to Reproduce              <!-- bug only -->
<steps>

## Expected / Actual                <!-- bug only -->
Expected: <expected behavior>
Actual: <actual behavior>

## Acceptance Criteria              <!-- feat only -->
- [ ] <criterion>

## Suggestions
<suggestions or N/A>

## Open Questions                   <!-- omit if none -->
<questions>
```

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Follow the body template exactly — no header or order changes. Title format: `<type>: <title>`. Never create without explicit confirmation. Assign every issue to the current user with `--assignee @me`. Stop if `gh` is missing or unauthenticated. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
