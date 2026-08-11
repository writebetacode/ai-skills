---
name: pr
description: Create or update a pull request or merge request with a human-readable title and structured description, on GitHub or GitLab, and move an existing one between draft and ready. Use when the user wants to open or update a PR or MR for work on the current branch, or to mark one as draft or ready for review. This is the pre-merge step: "ready" here means ready for a reviewer, never ready to publish a release.
argument-hint: "[target-branch] [draft]"
allowed-tools: "Bash(git ls-remote --heads origin:*), Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh api user:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab mr view:*), Bash(glab mr list:*), Bash(glab issue view:*), Bash(glab api user:*), Bash(jq -r .username:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git branch --show-current:*), Bash(git merge-base:*), Bash(git status --short:*)"
---

# PR

One skill for both forges. What follows is host-agnostic; the commands live in the host's reference file.

## Host

Resolve the forge from the `origin` remote, then read `${CLAUDE_SKILL_DIR}/github.md` for GitHub or `${CLAUDE_SKILL_DIR}/gitlab.md` for GitLab before running anything -- it carries the command for every operation named below. Where that path arrives unexpanded the runtime is not Claude Code: read the file of that name from this skill's own directory instead -- `~/.gemini/skills/pr/<file>.md` under Gemini CLI -- rather than treating the reference as missing. Where a self-hosted URL settles nothing, read both files and run each CLI's `repo-id`, taking the one that resolves; if both do or neither does, ask the user rather than guessing. Say "pull request" or "merge request" to match the host once resolved.

A missing CLI stops the run rather than being routed around: tell the user which one to install, with the URL from the reference file, and never reach for the other forge's CLI or a raw `curl` against the API.

Pass every description as a file path -- write the composed body to a temp file outside the repo and let the CLI read it. Retyping body text into a command is what breaks a description that has to arrive byte-exact.

## Workflow

Run `auth` first; stop on failure. Gather in parallel: `git branch --show-current`, the remote URL, `whoami`, `git status --short`, and the branch's PR/MR state via `view`. Warn on uncommitted changes.

Resolve the target branch from arguments, or auto-detect by matching branch-name prefix against other local branches, falling back to `git merge-base` against the repo's default branch -- resolve it via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), or `git remote show origin` parsed for `HEAD branch:` if that ref is missing. Never assume `main`: the repo may default to `develop`, `master`, or `trunk`.

The head is the current branch gathered above, and travels to `create` by name rather than being left to the CLI default. Both forges default it to whatever is checked out, which is silently wrong the moment the session has moved on -- and a stacked run has several sibling branches alive at once, so a PR opened from the wrong one still looks right. Naming it also costs `gh` the prompt it would otherwise raise to push an unpushed branch, so the skill pushes for itself: read the remote head with `git ls-remote --heads origin <head>`, and where that comes back empty or carrying a SHA other than the local one, run `git push -u origin <head>` before `create` or `update-description`. A create against a head the remote lacks fails outright, and an update against a stale one describes commits the reviewer cannot see.

Draft a human-readable title under 70 characters covering the combined changes. Compose the description from the template, write it to a temp file, then run `create` with the title, body path, base, head, and username -- adding draft when "draft" appears in the arguments -- or `update-description` following the Update Path below. An update redrafts the title too, against the combined changes as they now stand: where it differs from the one `view` reported, run `title` alongside the description. Display the URL the CLI returns.

Run `draft` or `ready` only when the request asks for the move: "mark it ready", "back to draft". `view` already reported the current state, so a move that would change nothing is reported instead of run. Where the same request also revises the description, update first and toggle after, since marking ready is what puts the body in front of reviewers.

## Update Path

Updating replaces the description wholesale, and reviewer bots, teammates, and prior manual edits all write into that same field. You own the fenced region and nothing else. Run `description` to fetch the current text, then locate your region, in this order:

1. **Both markers present** -- replace everything between them.
2. **Markers absent or unpaired** -- find the contiguous run of template sections from the first `## Tickets` heading and replace that run in place. A previous update owned it whether it predates the markers or lost them since, and a `## Why` section from an earlier version of the template is part of that run and goes with it. An unpaired opener never acts as a boundary; a hand-deleted closer would otherwise swallow the rest of the description.
3. **Neither** -- insert at the top. Only here: inserting while a template-shaped run exists is what produces two bodies, and later updates compound it.

Match markers on the token alone -- `pr-body:start`, `pr-body:end` -- ignoring whitespace inside the comment, since serializers respace HTML comments in transit. Recognize `mr-body:start` and `mr-body:end` as legacy equivalents from earlier versions of this skill, and rewrite them to the canonical token on the next update. Rule 2 is what survives a serializer that strips markers outright.

Everything outside your region survives byte-for-byte, in place, whoever wrote it: never reword, resummarize, reformat, template-conform, relocate, or regenerate it from the diff. On an ambiguous boundary, carry content forward rather than drop it -- a duplicated line is recoverable, deleted review feedback is not. Never skip an update or leave the description stale to avoid an awkward layout.

## Body Template

Use this exact structure, fence markers included. Omit Breaking Changes and Dependencies when not applicable. The markers delimit the region this skill owns and rewrites on update; everything outside them is preserved untouched.

The reviewer has the diff, so the body orients rather than restates it. Changes carries at most ten bullets; where the change touches more files than that, roll the remainder into one bullet per category naming the file count and what they share.

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

Always assign to the current user: `@me` on GitHub, a `whoami` username on GitLab, which has no `@me`. The reference file owns that difference -- pass the assignee it names and never hardcode one.

Never reference a host-native issue without validating it via `issue-view` first. Jira references are informational only -- neither forge closes a Jira issue on merge, so never apply a closing keyword (`Closes`, `Fixes`, `Resolves`) to a Jira key.

Never compose a remote command from memory -- every one comes from the host's reference file, and an operation it does not cover is reported as unsupported rather than improvised.

A toggle the forge refuses is reported as it stands, never simulated by other means: converting to draft is plan-dependent on GitHub.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Push violation:** forcing a head onto the remote, or pushing any branch but the head. `git push -u origin <head>` refused as non-fast-forward means the remote branch carries commits the local one does not: report the refusal and stop, since `--force` and `--force-with-lease` discard whatever a teammate or a rebase put there. That same `git push -u origin <head>` against a branch the remote lacks, or one it has behind the local head, is acceptable.

**Title violation:** any title that is not a plain-English, human-readable sentence -- raw branch names, ticket slugs, kebab-case, or machine-style identifiers must be rewritten before create/update. `fix/auth-token-refresh` or `PROJ-123` are violations, as is a `Draft:` prefix written here to mark state the `draft` operation owns; "Fix authentication token refresh on expired sessions" is acceptable.

**Body violation:** any body off the exact template -- Tickets, Summary, and Changes in that order using the prescribed markdown. Freeform prose, generic layouts, and invented sections must be corrected before create/update, `## Test Plan` and a reinstated `## Why` among them. A fenced region opening at `## Summary` with no `## Tickets`, or carrying either of those two sections, is a violation; one running Tickets, Summary, and Changes in that order, with Breaking Changes and Dependencies present only where they apply, is acceptable. This governs the fenced region alone: content outside it that you did not write is never a violation whatever its shape, and must not be trimmed or template-conformed to satisfy this rule.

**Fence violation:** composing any content of your own outside the markers, on create or on update -- the body you write is the fenced region and nothing else. Appending a `## Notes for Reviewers` section below `pr-body:end`, or any other commentary addressed to the reviewer, is a violation on both paths; what would go in one belongs in Summary, and a section of that name left there by a teammate or a bot is preserved as written rather than claimed as yours.

**Length violation:** a Summary past two sentences, a Changes bullet running longer than one line, or a Changes list past ten bullets. The body is read before the diff and never instead of it, so a bullet that needs a paragraph after it is a bullet whose reasoning belongs in Summary or nowhere.

## User Input

$ARGUMENTS
