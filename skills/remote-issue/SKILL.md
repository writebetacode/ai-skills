---
name: remote-issue
description: Create a consistently-formatted issue on GitHub or GitLab, or a work item in Jira, prompting for the tracker and the fields it requires. Use when filing or logging a bug, feature request, chore, or question against any of them, or when opening a ticket, an issue, or a work item to track work that has not been started.
argument-hint: "[title]"
---

# Remote Issue

One skill for all three trackers. The commands belong to the `gh`, `glab`, and `acli` agents; what follows is tracker-agnostic.

## Tracker

Ask which tracker unless the arguments settle it -- a project key like `PROJ-123` or the word "jira" means Jira, "github" or "gh" means GitHub, "gitlab" or "glab" means GitLab. Never infer from the git remote: a repo on GitHub may track its work in Jira, and filing in the wrong tracker is not quietly undone. Offer the forge matching `origin` first, since it is the likelier answer, but as a default to confirm rather than a decision already made.

| Tracker | Agent | Files a | Scoped by |
| --- | --- | --- | --- |
| GitHub | `gh` | issue | the working directory's repo |
| GitLab | `glab` | issue | the working directory's project |
| Jira | `acli` | work item | a project key, unrelated to the working directory |

Dispatch `auth` to the chosen agent and stop on failure, then resume it with `SendMessage` for the create. Send `op:` and its parameters one per line, and pass the description as a file path -- write the composed body to a temp file outside the repo, so the bytes never travel as prose in a message.

Two failures stop the run rather than routing around it. If the agent cannot be spawned, it is not installed: name it and say so. If it reports the CLI missing, tell the user which CLI to install, with the URL it gave. Never fall back to running the command here in either case.

## Workflow

Parse the arguments for a title, then prompt for what is missing, one field at a time. Required on every tracker: type, title, description, priority. Jira additionally requires a project key, and its work item type must be one that project defines -- `Epic`, `Story`, `Task`, `Bug`. Optional everywhere: labels, parent, and the body sections below.

Build the body from the template, omitting skipped sections. Show the finished title and body for edits, then write the body to a temp file and dispatch `issue-create`. Display the key and URL from the agent's report.

Where a field lands differs by tracker, because Jira models as fields what the forges leave to the body:

| Field | GitHub / GitLab | Jira |
| --- | --- | --- |
| type | `## Type` in the body, and the title prefix | `--type`, required; no title prefix and no body section |
| title | `--title`, formatted `<type>: <title>` | `--summary`, no type prefix -- the type is a field |
| priority | `## Priority` in the body -- neither forge has a priority field | `## Priority` in the body: `acli` has no `--priority` flag |
| project | the working directory's repo or project | `--project <KEY>` |
| assignee | `@me` on GitHub; a `whoami` username on GitLab, which has no `@me` | `@me` |
| labels | `--label` when given | `--label` when given |
| parent | `--parent` on GitHub; `--epic` on GitLab, an epic id on a paid tier | `--parent` |

GitHub issue types are an org-level feature many repos do not enable, so `--type` goes up only when asked for explicitly; the body's `## Type` section carries it otherwise. GitLab has no issue-type flag at all, so the body always carries it there.

## Issue Body Template

```markdown
## Type                             <!-- GitHub and GitLab; a field on Jira -->
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

Jira renders plain text, not GitHub-flavored markdown: headings stay, but nothing in the body should depend on markdown for meaning. Keep task lists and code fences out of a Jira description unless the user asks for them. Both forges render the template as written.

## Rules

Follow the body template exactly -- no header or order changes, beyond dropping `## Type` on Jira where it is a real field. Never create without explicit confirmation of the finished title and body. Assign every issue to the current user: `@me` where the CLI supports it, a `whoami` username on GitLab, which does not.

Never invent a project key or a work item type. Both are the user's to supply, and a rejected create is brought back to them rather than retried against a guess.

Never compose a remote command here -- an operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Title violation:** a GitHub or GitLab title that is not `<type>: <title>`, or a Jira summary carrying a type prefix that duplicates the `--type` field. On a forge, `Login is broken` is a violation and `fix: login rejects valid tokens after refresh` is acceptable; on Jira the same text without the `fix:` is acceptable, and `Bug: login rejects valid tokens` is a violation because `--type` already carries it.

## User Input

$ARGUMENTS
