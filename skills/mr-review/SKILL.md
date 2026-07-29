---
name: mr-review
description: Review a GitLab merge request, write numbered findings to docs/mr-reviews/<mr#>.md, and post selected findings back to the MR as inline discussions. Use when reviewing an MR on GitLab, posting review comments, or approving and revoking approval.
---

# MR Review

Reviewing and posting are separate. A review run writes a local file and posts nothing.

## Workflow

Verify `glab auth status`; stop on failure. Resolve the MR from `$ARGUMENTS` -- a number, branch name, or URL -- falling back to the current branch's open MR. Confirm the working directory is the MR's project by comparing `glab repo view --output json --jq .path_with_namespace` against the MR's; if they disagree, stop rather than writing findings into an unrelated repo.

Gather in parallel:

```sh
glab mr view <mr> --output json --jq '{iid,title,description,author:.author.username,source:.source_branch,target:.target_branch,sha,state,draft}'
glab mr diff <mr> --raw
glab mr view <mr> --comments
```

Read the diff in full, then read the surrounding code for every file it touches -- a hunk shows what changed, never whether it is correct against the code it lands in. Where the MR's head SHA differs from the local branch tip, say so: the working tree is not what is being reviewed.

Every question the diff raises is yours to answer first. Chase them as they surface, alongside the findings rather than after them: read the callers, the definition, the tests, the git history, the linked issue. A question survives to the report only once the repository has failed to settle it, and it carries what you looked at, so the author is asked for what only the author knows -- intent, an external system, a decision made off the diff -- and never for what a search would have told you.

Write `docs/mr-reviews/<mr#>.md`, creating directories as needed. Leave it unstaged and never gitignore it. Show the numbered findings and stop.

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
# MR !<iid> -- <title>

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

Head each section with the MR head SHA it was reviewed at, from `.sha`, chronologically, newest last. If that SHA already heads a section the revision has been reviewed: say so and stop, unless asked for a re-read.

Re-reviewing appends a section and continues numbering upward from the highest number in the file, so a number already posted keeps pointing at the same finding. Mark superseded findings `(resolved in <short-sha>)` in place -- never renumber, never delete -- and `(posted <YYYY-MM-DD>)` when a post succeeds.

## Posting

Only on an explicit request naming findings -- "post 2 and 5", "send the should-changes", "post everything". "Review this MR" is never such a request. Ask when the selection is ambiguous. List the findings and show the comment bodies, then post on confirmation.

Each finding becomes its own resolvable thread:

```sh
glab mr note create <mr> --file <path> --line <n> -m <body>      # line in the new version
glab mr note create <mr> --file <path> --old-line <n> -m <body>  # removed line
glab mr note create <mr> --file <path> -m <body>                 # whole file
glab mr note create <mr> -m <body>                               # no file anchor
```

`--line` and `--old-line` require `--file` and cannot be combined; `--file` cannot combine with `--reply` or `--unique`. Comments target the latest diff version, so compare the section's SHA against the MR's current `.sha` first: if they differ the author has pushed since, and every anchor must be re-read against the new diff or it lands on the wrong line.

A comment is the finding's own summary line, bolded and numbered, then its discussion:

````markdown
**issue (blocking): the handle is never closed on the error path** (2)

<what you observed, the consequence, and what would resolve it>

```suggestion:-0+0
<replacement line(s)>
```
````

`-0+0` is the anchored line alone; `-1+2` extends one above and two below. The block replaces exactly that range and is one click from being committed, so it must be complete, correctly indented, and valid where it lands. Offer one only where you have read the replaced lines and the fix is unambiguous; use prose for anything needing judgment, touching multiple sites, or inferring intent.

Report each post individually and mark it in the file. Never mark a finding posted unless the command succeeded.

## Voice

The author reads these without the context that produced them, and they outlive the exchange. Write to the code, not the person: name the function or line rather than "you" or "your". State what you observed, what follows from it, and what would resolve it; where you are inferring intent, say so ("unless `x` guarantees this is non-empty, ..."). Drop softeners -- "just", "simply", "obviously" -- and exclamation marks. Short, specific, and technically grounded is the collegial register.

**Voice violation:** any comment addressing the author rather than the code, assigning blame or carelessness, or asking a rhetorical question in place of a statement. "You forgot to close the file handle" and "did you really mean to swallow this error?" are violations; "the handle is never closed on the error path, so the descriptor leaks under repeated failures" and "this discards the error -- was that intended, or should it propagate?" are acceptable.

## Approval

`glab mr approve <mr> --sha <head-sha>` and `glab mr revoke <mr>`, on explicit request only. `--sha` keeps approval off a revision you did not read. Say that approval is recorded against the user's GitLab account and endorses an AI-produced review, and never approve over unresolved Should-change findings without confirmation.

## Rules

Producing the report is the whole of a review run: a verdict is never itself an approval.

Never invent a line number, file path, or consequence. Never claim anything was run or tested; describe inspected code as inspected -- a question you answered by reading says what you read. Review the diff on its merits, not the author's.

**Question violation:** a question the repository answers. Anything the code, the tests, the history, or the linked issue settles is a finding or nothing at all.

Restrict generated output -- commits, PRs, issues, comments, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Numbering violation:** a finding written without a number, or a number reused for a different finding, must be corrected before the report is shown.

**Scope violation:** posting, approving, or revoking without an explicit user instruction naming the action.

## User Input

$ARGUMENTS
