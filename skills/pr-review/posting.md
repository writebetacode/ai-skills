# Submitting and Following Up

Read on entering either mode from the Workflow in `SKILL.md`. Host resolution, the suggestion-fence and verdict tables, the finding numbering and its markers, and the Voice rules are already loaded from there and are not repeated here; the commands come from the host's `github.md` or `gitlab.md`, already read.

## Submit

Two ways in. A submit run sends every finding at once; a later request naming findings -- "post 2 and 5", "send the should-changes" -- sends only those, and an ambiguous selection is asked about before anything goes up. What goes up is findings and the Verdict; the report's Further review section stays behind in the file, per the Further review violation in `SKILL.md`. A finding marked `(also raised in thread <id>)` is held back too and named as held, since the point already has a thread -- it goes up only where the request names its number.

Compare the section's SHA against the current head first. If they differ the author has pushed since, and every anchor and quoted line must be re-read against the new diff, in the checkout the review left standing once it is moved to the new head, before anything goes up: a stale head is refused rather than relocating a comment onto whatever now sits at that line.

Write every body to a temp file outside the repo. On GitHub the review is one call -- `review-batch`, carrying the head SHA, the event, a summary body, and one entry per anchored finding -- so it arrives as a single notification and lands whole or not at all. A finding with no line anchor cannot ride in that array and goes into the summary body instead, under its own summary line and its own hidden marker rather than a visible number. A finding anchored to a range goes up as a multi-line comment spanning it, never collapsed onto its first line -- that is what puts the evidence under the comment when the report's quote of the anchored lines is the block being dropped. On GitLab there is no batch: run one `comment` per finding, keyed by finding number, with the anchor you recorded -- a line or a range in the new version, a removed line, a whole file, or no file anchor -- and the verdict separately afterwards.

On GitHub the review event follows the report's Verdict: changes needed submits `REQUEST_CHANGES`, comment only submits `COMMENT`. GitLab has no event to set -- changes needed posts the summary as a note and reports the state unsupported, per the verdict table in `SKILL.md`. Approve is the exception on both -- the summary goes up as a comment or a note and the approval is reported as waiting to be named, unless the request that started the run named it.

The body is the finding's summary line, bolded, then the discussion carried across verbatim from the report. Never re-expand it for the forge: the two-sentence cap is what the author reads, and the thread is where anything longer belongs once they ask.

The number is how you say "post 2 and 5" and how a thread is keyed back to its finding; it means nothing to the people reading the PR, who never saw the report. So it travels as `<!-- pr-review:finding-<N> -->` on the body's first line, which both forges render as nothing while the API keeps it in the body verbatim.

````markdown
<!-- pr-review:finding-2 -->
**issue (blocking): the handle is never closed on the error path**

<the finding's two sentences, as written in the report>

```go
// src/handler.go:41 -- <what this site establishes>
<the off-diff lines the claim rests on>
```

```suggestion
<replacement line(s)>
```
````

The comment already sits on its own line, so drop the report's quote of the anchored lines and carry the quotes the author cannot see from the thread -- the caller, the definition, the test that would still pass, the guideline the finding cites -- byte-identical to the report's and with the same `<file>:<line-range>` label. A finding whose evidence is only the anchored lines posts with no quote block at all, and one with no line anchor carries its quotes into the summary body under the same hidden marker.

A suggestion block replaces exactly the anchored range and is one click from being committed, so it must be complete, correctly indented, and valid where it lands. Offer one only where you have read the replaced lines and the fix is unambiguous; use prose for anything needing judgment, touching multiple sites, or inferring intent. Use the host's fence from the table in `SKILL.md`.

Mark the file per finding individually -- a finding is `(posted <YYYY-MM-DD>, thread <id>)` only against its own success, and that id is how a follow-up run finds the thread again. A batched review returns the review id and not the per-comment ids, so run `thread-list` afterwards and key each thread to its finding by the `<!-- pr-review:finding-<N> -->` marker its body carries. Neither forge guards against a double-post on an anchored comment, so a result you cannot match to a finding is checked with `thread-list` before anything is retried.

**Number visibility violation:** a finding number reaching the rendered text of anything posted -- a comment body, the summary body, or a thread reply -- rather than living only inside the marker. Everyone reading the PR is reading a numbering scheme from a file they do not have. A body ending `**issue (blocking): the handle is never closed on the error path** (2)` is a violation, and so is a reply opening "as finding 3 noted"; that same body under `<!-- pr-review:finding-2 -->`, and a reply naming the other point by what it says rather than by its number, are acceptable.

## Follow Up

Run `thread-list` and resolve every thread against the report: by the id recorded beside a finding, or where none was recorded -- a review posted before ids were kept -- by the `<!-- pr-review:finding-<N> -->` marker its body carries, or by its summary line where the marker is absent, since a review may predate it and some Markdown pipelines strip HTML comments. A thread matching none of the three belongs to someone else and is reported as context, never answered as though it were yours; a summary line matching two findings is reported as ambiguous rather than assigned to either.

Report each finding's thread as replied, unresolved, or resolved, quoting what came back. Resolution state is not uniform: GitLab reports it, and GitHub's comment listing does not carry it, so say the state is unavailable rather than inferring it from a reply.

Then do the work the reply asks for. A reply pointing at code is checked against that code in the worktree before answering, and quoted back the same way a finding quotes, so an author who says the deadline comes from the handler gets a response carrying the handler's own lines; the investigation obligation is the same one the review ran under, and a reply the repository settles is answered rather than deferred. A finding the reply resolves is marked `(settled in thread)` in place and recommended for resolution. A reply holds to the two-sentence cap a finding does, with its quotes uncounted: the author is mid-thread and reading on a phone as often as not.

Replies post only on a request naming which threads to answer, one `reply` per thread id, bodies written to a temp file outside the repo like any other. Never resolve, unresolve, or delete a thread: resolution is the author's signal that they acted on it, and closing it here erases the record that anyone disagreed.
