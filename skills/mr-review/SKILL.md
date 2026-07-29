---
name: mr-review
description: Review a GitLab merge request, write numbered findings to docs/mr-reviews/<mr#>.md, and post selected findings back to the MR as inline discussions. Use when reviewing an MR on GitLab, posting review comments, or approving and revoking approval.
---

# MR Review

Reviewing and posting are separate. A review run writes a local file and posts nothing; comments go up only on a later request naming which findings to send.

## Workflow

Verify `glab auth status`; stop on failure. Resolve the MR from `$ARGUMENTS` -- a number, branch name, or URL -- falling back to the current branch's open MR. Confirm the working directory is the MR's project by comparing `glab repo view --output json --jq .path_with_namespace` against the MR's; if they disagree, stop rather than writing findings into an unrelated repo.

Gather in parallel:

```sh
glab mr view <mr> --output json --jq '{iid,title,description,author:.author.username,source:.source_branch,target:.target_branch,sha,state,draft}'
glab mr diff <mr> --raw
glab mr view <mr> --comments
```

Read the diff in full, then read the surrounding code for every file it touches -- a hunk shows what changed, never whether it is correct against the code it lands in. Where the MR's head SHA differs from the local branch tip, say so: the working tree is not what is being reviewed.

Write `docs/mr-reviews/<mr#>.md`, creating directories as needed. Leave it unstaged and never gitignore it. Show the numbered findings and stop.

## Findings

Number every finding and never reuse a number -- numbers are how the user selects what to post. State the issue in one sentence and name its concrete consequence: what breaks, under what condition. A finding with no consequence to name belongs in Could change or nowhere. Anchor only to lines you have read; a wrong anchor puts the comment on unrelated code, and a finding with no anchor is written without one. Write findings in the voice below, in the summary line each will carry when posted -- report and comment share that text verbatim, so nothing is rewritten between them.

Each finding carries a [Conventional Comments](https://conventionalcomments.org/) label, and the section decides which labels are available and what decoration follows:

| Section | Labels | Decoration |
| --- | --- | --- |
| Good | `praise` | none |
| Should change | `issue`, `todo`, `chore` | `(blocking)` |
| Could change | `suggestion`, `nitpick`, `polish`, `typo` | `(non-blocking)` |
| Question | `question`, `thought`, `note` | none |

Pick the narrowest label that fits: `todo` and `chore` for the small and mechanical, `issue` for a real defect; `typo` and `nitpick` before `suggestion` when that is all it is. Add `(if-minor)` to a Could-change finding the author may resolve at their discretion. Never label a finding more severely than its consequence supports -- `issue (blocking)` on a preference is how a review stops being read.

```markdown
# MR !<iid> -- <title>

<source-branch> -> <target-branch> | @<author> | <state>
<url>

## <short-sha> -- <YYYY-MM-DD>

<N> files, +<x>/-<y>.

### Good
1. praise: <subject> -- `<file>:<line>`
   <what was done well; omit the section rather than pad it>

### Should change
2. issue (blocking): <subject> -- `<file>:<line>`
   <correctness, security, data loss, or breakage, and its consequence>

### Could change
3. suggestion (non-blocking): <subject> -- `<file>:<line>`
   <improvement the author may decline, and what it buys>

### Question
4. question: <subject> -- `<file>:<line>`
   <what the diff and surrounding code could not settle>

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

Comments follow [Conventional Comments](https://conventionalcomments.org/): `<label> [decorations]: <subject>`, then the discussion.

````markdown
**<label> [(decoration)]: <subject>** (<n>)

<what you observed, the consequence, and what would resolve it>

```suggestion:-0+0
<replacement line(s)>
```
````

`-0+0` is the anchored line alone; `-1+2` extends one above and two below. The block replaces exactly that range and is one click from being committed, so it must be complete, correctly indented, and valid where it lands. Offer one only where you have read the replaced lines and the fix is unambiguous; use prose for anything needing judgment, touching multiple sites, or inferring intent.

Report each post individually and mark it in the file. Never mark a finding posted unless the command succeeded.

## Voice

The author reads these without the context that produced them, and they outlive the exchange. Write to the code, not the person: name the function or line rather than "you" or "your". State what you observed, what follows from it, and what would resolve it; where you are inferring intent, say so ("unless `x` guarantees this is non-empty, ..."). Drop softeners -- "just", "simply", "obviously", "sorry to nitpick" -- and exclamation marks. A short, specific, technically grounded comment is the collegial one.

**Voice violation:** any comment addressing the author rather than the code, assigning blame or carelessness, or asking a rhetorical question in place of a statement. "You forgot to close the file handle" and "did you really mean to swallow this error?" are violations; "the handle is never closed on the error path, so the descriptor leaks under repeated failures" and "this discards the error -- was that intended, or should it propagate?" are acceptable.

## Approval

`glab mr approve <mr>` and `glab mr revoke <mr>` on explicit request only. Pass `--sha <head-sha>` so approval cannot land on a revision you did not read. State that approval is recorded against the user's GitLab account and endorses an AI-produced review. Never approve over unresolved Should-change findings without saying so and getting confirmation.

## Rules

Never post, approve, or revoke without an explicit request naming the action -- producing the report is the whole of a review run, and a verdict is never itself an approval.

Never invent a line number, file path, or consequence. Never claim anything was run or tested; describe inspected code as inspected. Review the diff on its merits, not the author's, and never fabricate Good findings to soften the rest.

Restrict generated output -- commits, PRs, issues, comments, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Numbering violation:** a finding written without a number, or a number reused for a different finding, must be corrected before the report is shown.

**Scope violation:** posting, approving, or revoking without an explicit user instruction naming the action.

## User Input

$ARGUMENTS
