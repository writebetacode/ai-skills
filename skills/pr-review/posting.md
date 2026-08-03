# Submitting and Following Up

Read on entering either mode from the Workflow in `SKILL.md`. Host resolution, the suggestion-fence and verdict tables, the finding numbering and its markers, and the Voice rules are already loaded from there and are not repeated here; the commands come from the host's `github.md` or `gitlab.md`, already read.

## Submit

Two ways in. A submit run sends every finding at once; a later request naming findings -- "post 2 and 5", "send the should-changes" -- sends only those, and an ambiguous selection is asked about before anything goes up.

Compare the section's SHA against the current head first. If they differ the author has pushed since, and every anchor must be re-read against the new diff before anything goes up: a stale head is refused rather than relocating a comment onto whatever now sits at that line.

Write every body to a temp file outside the repo. On GitHub the review is one call -- `review-batch`, carrying the head SHA, the event, a summary body, and one entry per anchored finding -- so it arrives as a single notification and lands whole or not at all. A finding with no line anchor cannot ride in that array and goes into the summary body instead, named by its number. On GitLab there is no batch: run one `comment` per finding, keyed by finding number, with the anchor you recorded -- a line in the new version, a removed line, a whole file, or no file anchor -- and the verdict separately afterwards.

The event follows the report's Verdict: changes needed submits `REQUEST_CHANGES`, comment only submits `COMMENT`. Approve is the exception -- it submits `COMMENT` and reports that the approval is waiting to be named, unless the request that started the run named it.

The body is the finding's summary line, bolded, with its number, then the discussion:

````markdown
**issue (blocking): the handle is never closed on the error path** (2)

<what you observed, the consequence, and what would resolve it>

```suggestion
<replacement line(s)>
```
````

A suggestion block replaces exactly the anchored range and is one click from being committed, so it must be complete, correctly indented, and valid where it lands. Offer one only where you have read the replaced lines and the fix is unambiguous; use prose for anything needing judgment, touching multiple sites, or inferring intent. Use the host's fence from the table in `SKILL.md`.

Mark the file per finding individually -- a finding is `(posted <YYYY-MM-DD>, thread <id>)` only against its own success, and that id is how a follow-up run finds the thread again. A batched review returns the review id and not the per-comment ids, so run `thread-list` afterwards and key each thread to its finding by the `(N)` marker its body carries. Neither forge guards against a double-post on an anchored comment, so a result you cannot match to a finding is checked with `thread-list` before anything is retried.

## Follow Up

Run `thread-list` and resolve every thread against the report: by the id recorded beside a finding, or where none was recorded -- a review posted before ids were kept -- by the `(N)` marker its body carries. A thread matching neither belongs to someone else and is reported as context, never answered as though it were yours.

Report each finding's thread as replied, unresolved, or resolved, quoting what came back. Resolution state is not uniform: GitLab reports it, and GitHub's comment listing does not carry it, so say the state is unavailable rather than inferring it from a reply.

Then do the work the reply asks for. A reply pointing at code is checked against that code before answering, so an author who says the deadline comes from the handler gets a response that has read the handler; the investigation obligation is the same one the review ran under, and a reply the repository settles is answered rather than deferred. A finding the reply resolves is marked `(settled in thread)` in place and recommended for resolution.

Replies post only on a request naming which threads to answer, one `reply` per thread id, bodies written to a temp file outside the repo like any other. Never resolve, unresolve, or delete a thread: resolution is the author's signal that they acted on it, and closing it here erases the record that anyone disagreed.
