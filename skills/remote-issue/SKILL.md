---
name: remote-issue
description: Create a consistently-formatted issue on GitHub or GitLab, or a work item in Jira, prompting for the tracker and the fields it requires. Use when filing or logging a bug, feature request, chore, or question against any of them, or when opening a ticket, an issue, or a work item to track work that has not been started.
argument-hint: "[title]"
allowed-tools: "Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh issue view:*), Bash(gh api user:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab issue view:*), Bash(glab api user:*), Bash(acli jira auth status:*), Bash(acli jira workitem view:*), Bash(jq -r .username:*)"
---

# Remote Issue

## Tracker

Ask which tracker unless the arguments settle it: a key like `PROJ-123` or "jira" means Jira, "github" or "gh" means GitHub, "gitlab" or "glab" means GitLab. Never infer it from the git remote, since a GitHub repo may track work in Jira and a misfiled issue isn't easily undone. Offer the forge matching `origin` first, as a default to confirm.

| Tracker | CLI | Reference file | Files a | Scoped by |
| --- | --- | --- | --- | --- |
| GitHub | `gh` | `${CLAUDE_SKILL_DIR}/github.md` | issue | the working directory's repo |
| GitLab | `glab` | `${CLAUDE_SKILL_DIR}/gitlab.md` | issue | the working directory's project |
| Jira | `acli` | `${CLAUDE_SKILL_DIR}/jira.md` | work item | a project key, unrelated to the working directory |

Read the chosen reference file before running anything; it has the command for every operation named below. Run `auth` and stop on failure.

If the CLI is missing, stop and tell the user which one to install, with the URL from the reference file. Never switch to another tracker's CLI or raw `curl`.

## Workflow

1. Take the title from the arguments, then ask for each missing field one at a time.
   - Required everywhere: type, title, description, priority.
   - Jira also requires a project key, and a work item type that project defines (`Epic`, `Story`, `Task`, `Bug`).
   - Optional everywhere: labels, parent, and the optional body sections.
2. Build the body from the template, leaving out skipped sections.
3. Show the finished title and body for edits.
4. Write the body to a temp file outside the repo (never retype it into a command) and run `issue-create`.
5. Show the key and URL the CLI returns.

Jira stores as fields some things the forges keep in the body:

| Field | GitHub / GitLab | Jira |
| --- | --- | --- |
| type | `## Type` in the body, and the title prefix | `--type`, required; no title prefix and no body section |
| title | `--title`, formatted `<type>: <title>` | `--summary`, no type prefix -- the type is a field |
| priority | `## Priority` in the body -- neither forge has a priority field | `## Priority` in the body: `acli` has no `--priority` flag |
| project | the working directory's repo or project | `--project <KEY>` |
| assignee | `@me` on GitHub; a `whoami` username on GitLab, which has no `@me` | `@me` |
| labels | `--label` when given | `--label` when given |
| parent | `--parent` on GitHub; `--epic` on GitLab, an epic id on a paid tier | `--parent` |

## Issue Body Template

```markdown
## Type                             <!-- GitHub and GitLab; a field on Jira -->
<type>

## Description
<description, at most 3 sentences>

## Priority
<low | medium | high>

## Steps to Reproduce              <!-- bug only -->
- <one line per step>

## Expected / Actual                <!-- bug only -->
Expected: <one line>
Actual: <one line>

## Acceptance Criteria              <!-- feat only -->
- [ ] <one line per criterion>

## Suggestions
<at most 2 sentences, or N/A>

## Open Questions                   <!-- omit if none -->
- <one line per question>
```

Jira renders plain text, not GitHub-flavored markdown: headings are fine, but nothing should depend on markdown for meaning, so leave task lists and code fences out unless asked.

## Rules

- Follow the template exactly, with no heading or order changes beyond dropping `## Type` on Jira.
- Never create without explicit confirmation of the finished title and body.
- Assign every issue to the current user.
- Never invent a project key or work item type; if the create is rejected, take it back to the user rather than retry a guess.
- Never write a remote command from memory; anything the reference file doesn't cover is unsupported.
- Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Length violation:** a Description past three sentences, Suggestions past two, or any Step, Criterion, or Open Question past one line. An issue is a handle for the work, not its record; detail that doesn't fit belongs in the PR or spec.

**Title violation:** a GitHub or GitLab title that isn't `<type>: <title>`, or a Jira summary with a type prefix repeating `--type`. On a forge, `Login is broken` is a violation and `fix: login rejects valid tokens after refresh` is acceptable. On Jira, the same text without `fix:` is acceptable, and `Bug: login rejects valid tokens` is a violation.

## User Input

$ARGUMENTS
