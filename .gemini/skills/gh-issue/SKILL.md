---
name: gh-issue
description: Create a consistently-formatted GitHub issue in the current repo. Use when filing a bug, feature request, chore, or question.
---

# GH Issue: Create Formatted GitHub Issue

## Workflow

1. **Prerequisites**: Run `gh auth status` and `gh repo view --json nameWithOwner --jq '.nameWithOwner'` — stop if either fails.
2. **Gather**: Parse the user's request for a title if provided. Prompt for any missing fields one at a time:
   - **Type**: `bug` | `feat` | `chore` | `docs` | `question`
   - **Title**: short imperative summary
   - **Description**: what, why, and any relevant context
   - **Priority**: `low` | `medium` | `high`
   - **Steps to Reproduce**: (bugs only — enter to skip)
   - **Expected / Actual Behavior**: (bugs only — enter to skip)
   - **Acceptance Criteria**: (feat only — enter to skip)
   - **Suggestions**: optional steps, ideas, or workarounds (enter to skip)
   - **Open Questions**: unresolved questions or unknowns (enter to skip)
3. **Draft**: Build the issue body using the standard template, omitting any optional sections that were skipped. Show the formatted title and body.
4. **Confirm**: Ask `Create issue? (yes/no/edit)`. On edit, accept changes and re-confirm.
5. **Execute**: `gh issue create --title "<type>: <title>" --body "<body>" --assignee @me`. Show issue URL.

## Issue Body Template

```
## Type
<type>

## Description
<description>

## Priority
<low | medium | high>

## Steps to Reproduce
<steps>

## Expected / Actual
Expected: <expected behavior>
Actual: <actual behavior>

## Acceptance Criteria
- [ ] <criterion>

## Suggestions
<suggestions or N/A>

## Open Questions
<questions>
```

Omit `Steps to Reproduce` and `Expected / Actual` unless type is `bug`.
Omit `Acceptance Criteria` unless type is `feat`.
Omit `Open Questions` if none provided.

## Rules

- Always use the standard body template — never change section headers or order
- Title is always formatted as `<type>: <title>`
- Never create without user confirmation
- Always `--assignee @me`
- Stop if `gh` is not installed or user is not authenticated
