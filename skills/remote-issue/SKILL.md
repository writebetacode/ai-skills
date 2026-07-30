---
name: remote-issue
description: Create a consistently-formatted issue on GitHub or a work item in Jira, prompting for the tracker and the fields it requires. Use when filing a bug, feature request, chore, or question against either tracker.
---

# Remote Issue

One skill for both trackers. The commands belong to the `gh` and `acli` agents; what follows is tracker-agnostic.

## Tracker

Ask which tracker unless `$ARGUMENTS` settles it -- a project key like `PROJ-123` or the word "jira" means Jira, "github" or "gh" means GitHub. Never infer from the git remote: a repo on GitHub may track its work in Jira, and filing in the wrong tracker is not quietly undone.

| Tracker | Agent | Files a | Scoped by |
| --- | --- | --- | --- |
| GitHub | `gh` | issue | the working directory's repo |
| Jira | `acli` | work item | a project key, unrelated to the working directory |

Dispatch `auth` to the chosen agent and stop on failure, then resume it with `SendMessage` for the create. Send `op:` and its parameters one per line, and pass the description as a file path -- write the composed body to a temp file outside the repo, so the bytes never travel as prose in a message.

## Workflow

Parse `$ARGUMENTS` for a title, then prompt for what is missing, one field at a time. Required either way: type, title, description, priority. Jira additionally requires a project key, and its work item type must be one that project defines -- `Epic`, `Story`, `Task`, `Bug`. Optional in both: labels, parent, and the body sections below.

Build the body from the template, omitting skipped sections. Show the finished title and body for confirmation or edits, then write the body to a temp file and dispatch `issue-create`. Display the key and URL from the agent's report.

Where a field lands differs by tracker, because Jira models as fields what GitHub leaves to the body:

| Field | GitHub | Jira |
| --- | --- | --- |
| type | `## Type` in the body, and the title prefix | `--type`, required; no title prefix and no body section |
| title | `--title`, formatted `<type>: <title>` | `--summary`, no type prefix -- the type is a field |
| priority | `## Priority` in the body | `## Priority` in the body: `acli` has no `--priority` flag |
| project | the working directory's repo | `--project <KEY>` |
| assignee | `@me` | `@me` |
| labels, parent | `--label`, `--parent` when given | `--label`, `--parent` when given |

GitHub issue types are an org-level feature many repos do not enable, so `--type` goes up only when asked for explicitly; the body's `## Type` section carries it otherwise.

## Issue Body Template

```
## Type                             <!-- GitHub only; a field on Jira -->
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

Jira renders plain text, not GitHub-flavored markdown: headings stay, but nothing in the body should depend on markdown for meaning. Keep task lists and code fences out of a Jira description unless the user asks for them.

## Rules

Follow the body template exactly -- no header or order changes, beyond dropping `## Type` on Jira where it is a real field. Never create without explicit confirmation of the finished title and body. Assign every issue to the current user.

Never invent a project key or a work item type. Both are the user's to supply, and a rejected create is brought back to them rather than retried against a guess.

Never compose a remote command here -- an operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Title violation:** a GitHub title that is not `<type>: <title>`, or a Jira summary carrying a type prefix that duplicates the `--type` field.

## User Input

$ARGUMENTS
