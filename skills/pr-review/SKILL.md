---
name: pr-review
description: Review a pull request or merge request on GitHub or GitLab, write numbered findings to docs/pr-reviews/<number>.md, and post selected findings back as inline comments. Use when reviewing a PR or MR, posting review comments, or approving and revoking approval.
---

# PR Review

Reviewing and posting are separate. A review run writes a local file and posts nothing.

## Host

Resolve the forge from the `origin` remote, then dispatch every remote operation to that host's agent -- `gh` for GitHub, `glab` for GitLab -- via the `Agent` tool, resuming it with `SendMessage` for later operations in the same run. Where a self-hosted URL settles nothing, ask each agent for `repo-id` and take the one that resolves; if both do or neither does, ask the user rather than guessing. Say "pull request" or "merge request" to match the host once resolved.

Send `op:` and its parameters, one per line. Every comment body travels as a file path, never as prose in a message: the summary line, the anchor, and any suggestion block have to arrive byte-exact, and re-emitting them into a message is where an indent or a line number shifts.

The agent owns the commands. This skill owns what the comment says -- including the suggestion dialect, which is a property of the body, not of the invocation:

| Host | Suggestion fence | Range |
| --- | --- | --- |
| GitHub | ` ```suggestion ` | the comment's own anchor range |
| GitLab | ` ```suggestion:-0+0 ` | offsets in the fence: `-0+0` is the anchored line alone, `-1+2` extends one above and two below |

## Workflow

Dispatch `auth`; stop on failure. Resolve the PR/MR from `$ARGUMENTS` -- a number, branch name, or URL -- falling back to the current branch's open one. Confirm the working directory is the right project by comparing `repo-id` against the PR/MR's; if they disagree, stop rather than writing findings into an unrelated repo.

Gather in parallel via the agent: `view`, `diff`, `threads`.

Read the diff in full, then read the surrounding code for every file it touches -- a hunk shows what changed, never whether it is correct against the code it lands in. Where the head SHA differs from the local branch tip, say so: the working tree is not what is being reviewed.

Every question the diff raises is yours to answer first. Chase them as they surface, alongside the findings rather than after them: read the callers, the definition, the tests, the git history, the linked issue. A question survives to the report only once the repository has failed to settle it, and it carries what you looked at, so the author is asked for what only the author knows -- intent, an external system, a decision made off the diff -- and never for what a search would have told them.

Write `docs/pr-reviews/<number>.md`, creating directories as needed. Leave it unstaged and never gitignore it. Show the numbered findings and stop.

## Findings

Number every finding and never reuse a number -- numbers are how the user selects what to post. State the issue in one sentence and name its concrete consequence: what breaks, under what condition. A finding with no consequence to name belongs in Could change or nowhere. Anchor only to lines you have read; a wrong anchor puts the comment on unrelated code, and a finding with no anchor is written without one.

Write each summary line in the voice below, once: posting reuses it verbatim. Labels follow [Conventional Comments](https://conventionalcomments.org/), and the section decides which are available and what decoration follows:

| Section | Labels | Decoration |
| --- | --- | --- |
| Should change | `issue`, `todo`, `chore` | `(blocking)` |
| Could change | `suggestion`, `nitpick`, `polish`, `typo` | `(non-blocking)` |
| Question | `question`, `thought`, `note` | none |

Pick the narrowest label that fits -- `todo` over `issue` for the small and mechanical, `typo` or `nitpick` over `suggestion` when that is all it is -- and never one more severe than the consequence supports. Add `(if-minor)` where the author may resolve at their discretion.

```markdown
# <PR|MR> <#|!><number> -- <title>

<source-branch> -> <target-branch> | @<author> | <state>
<url>

## <short-sha> -- <YYYY-MM-DD>

<N> files, +<x>/-<y>.

### Should change
1. issue (blocking): <subject> -- `<file>:<line>`
   <correctness, security, data loss, or breakage, and its consequence>

### Could change
2. suggestion (non-blocking): <subject> -- `<file>:<line>`
   <improvement the author may decline, and what it buys>

### Question
3. question: <subject> -- `<file>:<line>`
   <what you checked and what it showed, then the part only the author can settle>

### Verdict
<approve / changes needed / comment only>, and why in one or two sentences.
```

Head each section with the head SHA it was reviewed at -- `.sha` on GitLab, `headRefOid` on GitHub -- chronologically, newest last. If that SHA already heads a section the revision has been reviewed: say so and stop, unless asked for a re-read.

Re-reviewing appends a section and continues numbering upward from the highest number in the file, so a number already posted keeps pointing at the same finding. Mark superseded findings `(resolved in <short-sha>)` in place -- never renumber, never delete -- and `(posted <YYYY-MM-DD>)` when a post succeeds.

## Posting

Explicit request naming findings only -- "post 2 and 5", "send the should-changes". "Review this PR" is never such a request. Ask when the selection is ambiguous, then show the comment bodies and post on confirmation.

Comments target the latest diff, so compare the section's SHA against the current head first: if they differ the author has pushed since, and every anchor must be re-read against the new diff or it lands on the wrong line. The agent will refuse a stale head rather than relocate a comment, and re-deriving the anchor is this skill's job -- the diff is here, not there.

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

The agent reports one line per finding. Mark the file from those lines individually -- a finding is `(posted ...)` only against its own `OK`. Neither forge guards against a double-post on an anchored comment, so a report you cannot match to a finding is checked with `threads` before anything is retried.

## Voice

The author reads these without the context that produced them, and they outlive the exchange. Write to the code, not the person: name the function or line rather than "you" or "your". State what you observed, what follows from it, and what would resolve it; where you are inferring intent, say so ("unless `x` guarantees this is non-empty, ..."). Drop softeners -- "just", "simply", "obviously" -- and exclamation marks. Short, specific, and technically grounded is the collegial register.

**Voice violation:** any comment addressing the author rather than the code, assigning blame or carelessness, or asking a rhetorical question in place of a statement. "You forgot to close the file handle" and "did you really mean to swallow this error?" are violations; "the handle is never closed on the error path, so the descriptor leaks under repeated failures" and "this discards the error -- was that intended, or should it propagate?" are acceptable.

## Approval

Dispatch `approve` or `revoke` on explicit request only, pinned to the head SHA you read. GitLab records approval against that SHA directly; GitHub has no revoke, and dismissal needs the review id and elevated access, so the agent may report it unsupported. Say that approval is recorded against the user's account and endorses an AI-produced review, and never approve over unresolved Should-change findings without confirmation.

## Rules

Producing the report is the whole of a review run: a verdict is never itself an approval.

Never compose a remote command here. An operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call from this skill -- the tables are the single place those flags are maintained.

Never invent a line number, file path, or consequence. Never claim anything was run or tested; describe inspected code as inspected -- a question you answered by reading says what you read. Review the diff on its merits, not the author's.

**Question violation:** a question the repository answers. Anything the code, the tests, the history, or the linked issue settles is a finding or nothing at all.

Restrict generated output -- commits, PRs, issues, comments, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Numbering violation:** a finding written without a number, or a number reused for a different finding, must be corrected before the report is shown.

**Scope violation:** posting, approving, or revoking without an explicit user instruction naming the action.

## User Input

$ARGUMENTS
