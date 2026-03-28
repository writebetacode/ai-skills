---
name: gh-issue
description: Create a consistently-formatted GitHub issue in the current repo. Use when filing a bug, feature request, chore, or question.
---

# GH Issue: Create Formatted GitHub Issue

## Workflow

Start by verifying prerequisites with `gh auth status` and checking the repository name; stop immediately if either step fails. Parse any provided arguments for a title and then prompt the user for any missing fields, including the issue type, title, description, priority, and optional sections like reproduction steps or acceptance criteria. Construct the issue body using the standard template, carefully omitting any optional sections that were skipped during the gathering phase. Show the final formatted title and body to the user and ask for confirmation or edits. Once confirmed, create the issue using the GitHub CLI, ensuring the issue is assigned to the current user and the final URL is displayed.

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

Strictly adhere to the standard body template without changing section headers or their order. Always format the title as `<type>: <title>` and never create an issue without explicit user confirmation. Ensure all created issues are assigned to the current user with `--assignee @me`. Stop the process if the `gh` tool is not installed or if the user is not authenticated. Use only ASCII characters and never include AI attribution or "Co-Authored-By" lines in any output.
