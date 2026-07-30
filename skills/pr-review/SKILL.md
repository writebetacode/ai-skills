---
name: pr-review
description: Review a pull request or merge request on GitHub or GitLab, write numbered findings to docs/pr-reviews/<number>.md, and post selected findings back as inline comments. Use when reviewing a PR or MR, posting review comments, or approving and revoking approval.
---

# PR Review

Reviewing and posting are separate. A review run writes a local file and posts nothing.

## Host

Resolve the forge from the `origin` remote and dispatch every remote operation to that host's agent -- `gh` for GitHub, `glab` for GitLab -- via the `Agent` tool, resuming it with `SendMessage` within a run. Where a self-hosted URL settles nothing, ask each available agent for `repo-id` and take the one that resolves; if both do or neither does, ask the user. Say "pull request" or "merge request" to match the host once resolved.

Two failures stop the run rather than routing around it. If the agent cannot be spawned, it is not installed: name it and say so. If it reports the CLI missing, tell the user which CLI to install, with the URL it gave. Never fall back to running the command here in either case.

Send `op:` and its parameters one per line. Every comment body travels as a file path, never as prose in a message: the summary line, the anchor, and any suggestion block have to arrive byte-exact.

The agent owns the commands; this skill owns what the comment says -- including the suggestion dialect, which is a property of the body rather than the invocation:

| Host | Suggestion fence | Range |
| --- | --- | --- |
| GitHub | ` ```suggestion ` | the comment's own anchor range |
| GitLab | ` ```suggestion:-0+0 ` | offsets in the fence: `-0+0` is the anchored line alone, `-1+2` extends one above and two below |

## Workflow

Dispatch `auth`; stop on failure. Resolve the PR/MR from `$ARGUMENTS` -- a number, branch name, or URL -- falling back to the current branch's open one. Confirm the working directory is the right project by comparing `repo-id` against the PR/MR's; if they disagree, stop rather than writing findings into an unrelated repo.

Gather in parallel via the agent: `view`, `diff`, `threads`.

Read the diff in full, then read the surrounding code for every file it touches -- a hunk shows what changed, never whether it is correct against the code it lands in. Where the head SHA differs from the local branch tip, say so: the working tree is not what is being reviewed.

Every question the diff raises is yours to answer first, chased as it surfaces rather than deferred: the callers, the definition, the tests, the history, the linked issue. What the repository settles becomes a finding. What it cannot settle is still a finding, written so the author confirms rather than investigates: what you already checked, and the one part only they can supply -- intent, an external system, a decision made off the diff.

Write `docs/pr-reviews/<number>.md`, creating directories as needed. Leave it unstaged and never gitignore it. Show the numbered findings and stop.

The report is a file in someone's repo, so it lints like one: blank lines around every heading, list, and fenced block; a language on every fence; one top-level heading; no trailing whitespace; one trailing newline. Line length is the host repo's call, so never wrap prose to a column.

## Findings

A finding traces to the change: a line the diff touched, or code the change makes wrong -- a caller the new signature breaks, an invariant it now violates, a test it leaves stale. Surrounding code is read to judge that, never mined for findings of its own. A defect on untouched lines of a touched file is out of scope however visible, as is a refactor the diff merely makes tempting.

Number every finding and never reuse a number -- numbers are how the user selects what to post. State the issue in one sentence and name its concrete consequence: what breaks, under what condition. A finding with no consequence to name belongs in Could change or nowhere. Anchor only to lines you have read; a finding with no anchor is written without one.

Write each summary line once, in the voice below: posting reuses it verbatim. Labels follow [Conventional Comments](https://conventionalcomments.org/), and the section decides which are available and what decoration follows:

| Section | Labels | Decoration |
| --- | --- | --- |
| Should change | `issue`, `todo`, `chore` | `(blocking)` |
| Could change | `suggestion`, `nitpick`, `polish`, `typo` | `(non-blocking)` |

Pick the narrowest label that fits -- `todo` over `issue` for the small and mechanical, `typo` or `nitpick` over `suggestion` when that is all it is -- and never one more severe than the consequence supports. Add `(if-minor)` where the author may resolve at their discretion.

A finding the repository could not settle routes by consequence like any other: Should change where the unfavourable answer breaks something, Could change where it does not. It carries the condition in its text -- what must hold, what follows if it does not, and what you checked to get that far -- so the uncertainty is visible without a section of its own.

```markdown
# <PR|MR> <#|!><number> -- <title>

<!-- markdownlint-disable MD029 -- finding numbers are ids, not list positions -->

<source-branch> -> <target-branch> | @<author> | <state>
<url>

## <short-sha> -- <YYYY-MM-DD>

<N> files, +<x>/-<y>.

### Should change

1. issue (blocking): <subject> -- `<file>:<line>`
   <correctness, security, data loss, or breakage, and its consequence>

2. issue (blocking): <subject> -- `<file>:<line>`
   <unsettled: what must hold, what breaks if it does not, and what you checked>

### Could change

3. suggestion (non-blocking): <subject> -- `<file>:<line>`
   <improvement the author may decline, and what it buys>

### Verdict

<approve / changes needed / comment only>, and why in one or two sentences.
```

Head each section with the head SHA it was reviewed at -- `.sha` on GitLab, `headRefOid` on GitHub -- chronologically, newest last. If that SHA already heads a section the revision has been reviewed: say so and stop, unless asked for a re-read.

Re-reviewing appends a section and continues numbering upward from the highest number in the file, so a number already posted keeps pointing at the same finding. Mark superseded findings `(resolved in <short-sha>)` in place -- never renumber, never delete -- and `(posted <YYYY-MM-DD>)` when a post succeeds.

## Posting

Post only on an explicit request naming findings -- "post 2 and 5", "send the should-changes". Ask when the selection is ambiguous, then show the comment bodies and post on confirmation.

Compare the section's SHA against the current head first. If they differ the author has pushed since, and every anchor must be re-read against the new diff before anything goes up: the agent refuses a stale head rather than relocating a comment, and re-deriving the anchor is this skill's job, since the diff is here and not there.

Each finding becomes its own thread. Write its body to a temp file outside the repo, then dispatch one `comment` per finding, keyed by finding number, with the anchor you recorded: a line in the new version, a removed line, a whole file, or no file anchor.

The body is the finding's summary line, bolded, with its number, then the discussion:

````markdown
**issue (blocking): the handle is never closed on the error path** (2)

<what you observed, the consequence, and what would resolve it>

```suggestion
<replacement line(s)>
```
````

A suggestion block replaces exactly the anchored range and is one click from being committed, so it must be complete, correctly indented, and valid where it lands. Offer one only where you have read the replaced lines and the fix is unambiguous; use prose for anything needing judgment, touching multiple sites, or inferring intent. Use the host's fence from the table above.

Mark the file from the agent's per-finding report individually -- a finding is `(posted ...)` only against its own `OK`. Neither forge guards against a double-post on an anchored comment, so a report you cannot match to a finding is checked with `threads` before anything is retried.

## Voice

The author reads these without the context that produced them, and they outlive the exchange. Write to the code, not the person: name the function or line rather than "you" or "your". State what you observed, what follows from it, and what would resolve it; where you are inferring intent, say so ("unless `x` guarantees this is non-empty, ..."). Drop softeners -- "just", "simply", "obviously" -- and exclamation marks.

**Voice violation:** any comment addressing the author rather than the code, assigning blame or carelessness, or asking a rhetorical question in place of a statement. "You forgot to close the file handle" and "did you really mean to swallow this error?" are violations; "the handle is never closed on the error path, so the descriptor leaks under repeated failures" and "this discards the error -- was that intended, or should it propagate?" are acceptable.

## Approval

Dispatch `approve` or `revoke` on explicit request only, pinned to the head SHA you read. GitLab records approval against that SHA; GitHub has no revoke, and dismissal needs the review id and elevated access, so the agent may report it unsupported. Say that approval is recorded against the user's account and endorses an AI-produced review, and never approve over unresolved Should-change findings without confirmation.

## Rules

Producing the report is the whole of a review run: a verdict is never itself an approval.

Never compose a remote command here -- an operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call.

Never invent a line number, file path, or consequence. Never claim anything was run or tested; describe inspected code as inspected. Review the diff on its merits, not the author's.

**Relevance violation:** a finding that does not trace to the change -- a defect on untouched lines of a touched file, a remark on surrounding code, or a question the code, the tests, the history, or the linked issue already answers. "`parseConfig` has swallowed this error since before the diff" is a violation; "the early return added here skips the `defer` above it" is a finding.

**Numbering violation:** a finding written without a number, or a number reused for a different finding, must be corrected before the report is shown.

**Scope violation:** posting, approving, or revoking without an explicit user instruction naming the action. "Review this PR" is never such an instruction.

Restrict generated output -- commits, PRs, issues, comments, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
