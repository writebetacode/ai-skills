---
name: pr
description: Create or update a pull request or merge request with a conventional-commit title that carries its ticket number and a structured description, on GitHub or GitLab, and move an existing one between draft and ready. Use when the user wants to open or update a PR or MR for work on the current branch, or to mark one as draft or ready for review. This is the pre-merge step: "ready" here means ready for a reviewer, never ready to publish a release.
argument-hint: "[target-branch] [draft]"
allowed-tools: "Bash(git ls-remote --heads origin:*), Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh api user:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab mr view:*), Bash(glab mr list:*), Bash(glab issue view:*), Bash(glab api user:*), Bash(jq -r .username:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git branch --show-current:*), Bash(git merge-base:*), Bash(git status --short:*)"
---

# PR

## Host

Resolve the forge from the `origin` remote, then read `${CLAUDE_SKILL_DIR}/github.md` or `${CLAUDE_SKILL_DIR}/gitlab.md` before running anything; it has the command for every operation named below. If the path arrives unexpanded, you're not in Claude Code: read the same file from this skill's own installed directory instead (`~/.gemini/skills/pr/<file>.md` under Gemini CLI) rather than treating the reference as missing. If a self-hosted URL doesn't settle the forge, read both files and use whichever CLI's `repo-id` resolves; if both or neither do, ask. Once resolved, say "pull request" or "merge request" to match.

If the CLI is missing, stop and tell the user which one to install, with the URL from the reference file. Never switch to the other forge's CLI or raw `curl`.

## Workflow

1. **Gather.** Run `auth`; stop on failure. In parallel: `git branch --show-current`, the remote URL, `whoami`, `git status --short`, and the branch's PR/MR via `view`. Warn about uncommitted changes.
2. **Target branch.** From the arguments; otherwise match the branch-name prefix against other local branches; otherwise `git merge-base` against the default branch, found with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`), falling back to `HEAD branch:` from `git remote show origin` if that ref is missing. Never assume `main`.
3. **Push the head.** The head is the current branch, always passed to `create` by name: the CLI default is whatever is checked out, which goes wrong when a stacked run has sibling branches in play. If `git ls-remote --heads origin <head>` is empty or shows a different SHA from the local one, run `git push -u origin <head>` before `create` or `update-description`; otherwise create fails and an update describes commits the reviewer can't see.
4. **Title**, under 70 characters, covering all the changes: `<type>(<ticket>): <description>`, or `<type>: <description>` with no ticket.
   - type: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, or `ci`, whichever describes the change as a whole, from the branch prefix or its commits, defaulting to `chore`.
   - ticket: the one the Tickets section links, the first if several: a Jira key as written (`PROJ-123`) or a host issue as `#<n>`.
   - description: a plain-English phrase in imperative mood, starting lowercase.
5. **Body.** Fill in the Body Template and write it to a temp file outside the repo; never retype body text into a command.
6. **Create or update.** Create: `create` with title, body path, base, head, and username, plus draft if "draft" is in the arguments. Update: `update-description` per the Update Path, and redraft the title against the changes as they now stand, running `title` if it differs from what `view` returned. Show the URL the CLI returns.

Run `draft` or `ready` only when asked ("mark it ready", "back to draft"). If `view` shows it's already in that state, say so instead. If the same request changes the description, update first and toggle second.

## Update Path

An update replaces the whole description, which bots, teammates, and manual edits also write into. You own only the fenced region. Fetch the current text with `description`, then find your region, first match wins:

1. **Both markers present:** replace everything between them.
2. **Markers missing or unpaired:** replace, in place, the contiguous run of template sections starting at the first `## Tickets`. An unpaired opener is never a boundary; a deleted closer would otherwise swallow the rest.
3. **Neither:** insert at the top. Only here, since inserting beside a template-shaped run creates two bodies that later updates compound.

Match markers on the token alone (`pr-body:start`, `pr-body:end`), ignoring whitespace inside the comment, since serializers respace HTML comments.

Everything outside your region stays byte-for-byte in place, whoever wrote it: never reword, summarize, reformat, template-conform, move, or regenerate it. When a boundary is unclear, keep content rather than drop it; a duplicated line is fixable, deleted review feedback isn't. Never skip an update or leave the description stale to avoid an awkward layout.

## Body Template

Use this exact structure, markers included. The reviewer has the diff, so the body orients rather than restates. Changes has at most ten bullets; past that, roll the rest into one bullet per category with the file count and what they share.

```markdown
<!-- pr-body:start -->
<!-- Autogenerated. Everything inside this fence is rewritten on each update
     and any edits here will be lost. Add notes outside the fence; content
     there is preserved exactly as written. -->
## Tickets
[#<number>](<url>) -- <title>, or N/A

## Summary
<At most 2 sentences: what changed, and why it was worth doing.>

## Changes

**<Category>**
- `<file>`: <one line>
- `<file>`: <one line>

**<Category>**
- `<file>`: <one line>
<!-- pr-body:end -->
```

## Rules

- Always assign to the current user, with the assignee the reference file names; never hardcode one.
- Never reference a host-native issue without checking it with `issue-view` first.
- Jira references are informational: neither forge closes a Jira issue on merge, so never put a closing keyword (`Closes`, `Fixes`, `Resolves`) before a Jira key.
- Never write a remote command from memory; anything the reference file doesn't cover is unsupported.
- If the forge refuses a draft/ready toggle, report it; never simulate the state another way.
- Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Push violation:** force-pushing the head, or pushing any branch but the head. If `git push -u origin <head>` is refused as non-fast-forward, the remote has commits you don't: report it and stop, since `--force` and `--force-with-lease` discard what a teammate or rebase put there. The same push to a branch the remote lacks or has behind the local head is acceptable.

**Title violation:** a title off `<type>(<ticket>): <description>`, or `<type>: <description>` when there is no ticket: a missing or unlisted type, a ticket the Tickets section doesn't link, a scope other than the ticket, or a description that is a raw branch name, ticket slug, kebab-case, or other machine-style identifier; rewrite it before create/update. `fix/auth-token-refresh`, `PROJ-123`, "Fix authentication token refresh on expired sessions", `feat(auth): refresh expired tokens`, and `fix(PROJ-123): PROJ-123` are violations, and so is a `Draft:` prefix, since the `draft` operation owns that state. `fix(PROJ-123): refresh auth tokens on expired sessions`, `fix(#42): stop double-charging empty carts`, and, with no ticket, `feat: add retry to webhook delivery` are acceptable.

**Body violation:** a fenced region off the template, which is Tickets, Summary, and Changes in that order in the given markdown. Freeform prose, generic layouts, and invented sections are violations to correct before create/update, `## Test Plan`, `## Why`, and `## Breaking Changes` included, as is a region opening at `## Summary` without `## Tickets`. Tickets, Summary, and Changes in that order, and nothing else, is acceptable. This covers the fenced region alone: content outside it that you didn't write is never a violation and is never trimmed or reshaped to fit.

**Fence violation:** writing any content of your own outside the markers, on create or update. A `## Notes for Reviewers` section below `pr-body:end`, or any other note to the reviewer, is a violation; it belongs in Summary. A section of that name left by a teammate or bot is kept as written, not claimed.

**Length violation:** a Summary past two sentences, a Changes bullet past one line, or more than ten Changes bullets. A bullet needing a paragraph has reasoning that belongs in Summary or nowhere.

## User Input

$ARGUMENTS
