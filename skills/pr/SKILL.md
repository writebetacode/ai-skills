---
name: pr
description: Create or update a pull request or merge request with a human-readable title and structured description, on GitHub or GitLab, and move an existing one between draft and ready. Use when the user wants to open or update a PR or MR for work on the current branch, or to mark one as draft or ready for review. This is the pre-merge step: "ready" here means ready for a reviewer, never ready to publish a release.
argument-hint: "[target-branch] [draft]"
allowed-tools: "Bash(git ls-remote --heads origin:*), Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh api user:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab mr view:*), Bash(glab mr list:*), Bash(glab issue view:*), Bash(glab api user:*), Bash(jq -r .username:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git branch --show-current:*), Bash(git merge-base:*), Bash(git status --short:*)"
---

# PR

## Host

Resolve the forge from the `origin` remote. Before running anything, read `${CLAUDE_SKILL_DIR}/github.md` for GitHub or `${CLAUDE_SKILL_DIR}/gitlab.md` for GitLab. It has the command for every operation named below. If that path arrives unexpanded, you are not in Claude Code: read the same file from the skill's installed directory instead (`~/.gemini/skills/pr/<file>.md` under Gemini CLI). If a self-hosted URL doesn't settle the forge, read both files and run each CLI's `repo-id`, then use the one that resolves. If both or neither resolve, ask the user. Once resolved, say "pull request" or "merge request" to match the host.

If the CLI is missing, stop and tell the user which one to install, using the URL in the reference file. Never switch to the other forge's CLI or a raw `curl` against the API.

Write every description to a temp file outside the repo and pass the file to the CLI. Never retype body text into a command.

## Workflow

Run `auth` and stop if it fails. Gather in parallel: `git branch --show-current`, the remote URL, `whoami`, `git status --short`, and the branch's PR/MR through `view`. Warn about uncommitted changes.

Take the target branch from the arguments. Otherwise match the branch-name prefix against other local branches, and fall back to `git merge-base` against the default branch. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), or parse `HEAD branch:` from `git remote show origin` if that ref is missing. Never assume `main`.

Pass the head (the current branch gathered above) to `create` by name. Never leave it to the CLI default, which is whatever is checked out and goes wrong when a stacked run has several sibling branches in play. Push the head yourself first: if `git ls-remote --heads origin <head>` is empty or shows a SHA other than the local one, run `git push -u origin <head>` before `create` or `update-description`. Otherwise create fails outright, and an update describes commits the reviewer can't see.

Write a human-readable title under 70 characters covering all the changes. Fill in the Body Template, write it to a temp file, and run `create` with the title, body path, base, head, and username, adding draft if "draft" is in the arguments. To update, run `update-description` following the Update Path, and redraft the title against the changes as they now stand. If it differs from the title `view` returned, run `title` too. Show the URL the CLI returns.

Run `draft` or `ready` only when asked ("mark it ready", "back to draft"). If `view` shows the PR is already in that state, say so instead of running it. If the same request also changes the description, update first and toggle second.

## Update Path

An update replaces the whole description, and bots, teammates, and earlier manual edits all live in that same field. You own only the fenced region. Fetch the current text with `description`, then find your region in this order:

1. **Both markers present:** replace everything between them.
2. **Markers missing or unpaired:** find the contiguous run of template sections starting at the first `## Tickets` heading and replace that run in place, including any `## Why` section from an older template. An unpaired opener is never a boundary, since a deleted closer would otherwise swallow the rest of the description.
3. **Neither:** insert at the top. Only here, because inserting while a template-shaped run exists creates two bodies, and later updates compound it.

Match markers on the token alone (`pr-body:start`, `pr-body:end`), ignoring whitespace inside the comment, because serializers respace HTML comments. Treat `mr-body:start` and `mr-body:end` as legacy equivalents and rewrite them to the canonical token on the next update.

Everything outside your region stays byte-for-byte in place, whoever wrote it. Never reword, summarize, reformat, template-conform, move, or regenerate it. When a boundary is unclear, keep content rather than dropping it: a duplicated line can be fixed, deleted review feedback can't. Never skip an update or leave the description stale to avoid an awkward layout.

## Body Template

Use this exact structure, markers included. Leave out Breaking Changes and Dependencies when they don't apply. The reviewer has the diff, so the body orients them rather than restating it. Changes has at most ten bullets. If more files changed, roll the rest into one bullet per category giving the file count and what they have in common.

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

## Breaking Changes

<One line per break: what stops working, and what to do instead. Omit this section entirely when there are none.>

## Dependencies

<One line per dependency added, removed, or upgraded. Omit this section entirely when there are none.>
<!-- pr-body:end -->
```

## Rules

Always assign to the current user, using the assignee the reference file names. Never hardcode one.

Never reference a host-native issue without checking it with `issue-view` first. Jira references are for information only. Neither forge closes a Jira issue on merge, so never put a closing keyword (`Closes`, `Fixes`, `Resolves`) in front of a Jira key.

Never write a remote command from memory. Every command comes from the host's reference file, and an operation the file doesn't cover is reported as unsupported.

If the forge refuses a draft/ready toggle, report the refusal. Never simulate the state another way.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Push violation:** force-pushing the head, or pushing any branch other than the head. If `git push -u origin <head>` is refused as non-fast-forward, the remote has commits the local branch doesn't: report it and stop, because `--force` and `--force-with-lease` throw away whatever a teammate or a rebase put there. The same push to a branch the remote lacks, or has behind the local head, is acceptable.

**Title violation:** a title that isn't a plain-English sentence, such as a raw branch name, ticket slug, kebab-case, or other machine-style identifier. `fix/auth-token-refresh` and `PROJ-123` are violations, and so is a `Draft:` prefix, since the `draft` operation owns that state. "Fix authentication token refresh on expired sessions" is acceptable.

**Body violation:** a fenced region that departs from the template, which is Tickets, Summary, and Changes in that order in the given markdown. Freeform prose, generic layouts, and invented sections are violations, including `## Test Plan` and a reinstated `## Why`. A region that opens at `## Summary` without `## Tickets`, or contains either of those two sections, is a violation. Tickets, Summary, and Changes in order, with Breaking Changes and Dependencies only where they apply, is acceptable. This rule covers only the fenced region. Content outside it that you didn't write is never a violation, and must never be trimmed or reshaped to fit.

**Fence violation:** writing any content of your own outside the markers, on create or update. Adding a `## Notes for Reviewers` section below `pr-body:end`, or any other note to the reviewer, is a violation; that belongs in Summary. A section with that name left by a teammate or a bot is kept as written and not claimed as yours.

**Length violation:** a Summary longer than two sentences, a Changes bullet longer than one line, or more than ten Changes bullets. A bullet that needs a paragraph has reasoning that belongs in Summary or nowhere.

## User Input

$ARGUMENTS
