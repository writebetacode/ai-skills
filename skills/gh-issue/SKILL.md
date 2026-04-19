---
name: gh-issue
description: Create a consistently-formatted GitHub issue in the current repo. Use when filing a bug, feature request, chore, or question.
model: sonnet
---

# GH Issue: Create Formatted GitHub Issue

## Workflow

Verify prerequisites with `gh auth status` and check the repository name; stop immediately if either fails. Parse any provided arguments for a title, then prompt for missing fields: issue type, title, description, priority, and optional sections like reproduction steps or acceptance criteria. Build the body using the template below, omitting any optional sections that were skipped. Show the formatted title and body and get confirmation or edits. Once confirmed, create the issue via `gh issue create --assignee @me` and display the final URL.

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

## Rules

Strictly follow the body template without changing section headers or order. Always format the title as `<type>: <title>` and never create an issue without explicit user confirmation. Assign every created issue to the current user with `--assignee @me`. Stop if `gh` is not installed or the user is not authenticated. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
