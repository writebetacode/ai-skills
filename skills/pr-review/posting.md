# Submitting and Following Up

Read on entering either mode from the Workflow in `SKILL.md`. Host resolution, the verdict table, the finding shape, numbering and its markers, and the Voice rules are already loaded from there and are not repeated here; the commands come from the host's `github.md` or `gitlab.md`, already read.

## Submit

Two ways in. A submit run sends every active finding at once; a later request naming findings -- "post 2 and 5", "send the blocking ones" -- sends only those, and an ambiguous selection is asked about before anything goes up. What goes up is the findings, one comment each, and on GitHub the Verdict as the review's event -- nothing else, per the Summary and Withdrawal violations in `SKILL.md`. A finding marked `(linked to thread <id>)` -- or the older `(also raised in thread <id>)` -- goes up as a `reply` in that thread instead of as a new comment, carrying the same body a new comment would. A finding marked `(linked to comment <url>)` posts as an ordinary comment, since its summary already points back at the comment it joins.

Compare the SHA on the report's `Reviewed at` line against the current head first. If they differ the author has pushed since, and every anchor, reference, and example must be re-read against the new diff, in the checkout the review left standing once it is moved to the new head, before anything goes up: a stale head is refused rather than relocating a comment onto whatever now sits at that line.

On GitHub the review is one call -- `review-batch`, carrying the head SHA, the event, and one entry per anchored finding, with no review body -- so it arrives as a single notification and lands whole or not at all. A finding with no line anchor cannot ride in that array, and neither can a linked finding -- every entry needs a path and a line, and none can name a thread -- so once the review has landed each runs on its own, an unanchored finding as a `comment` with no file anchor and a linked one as a `reply`; none runs where the review was rejected. Where no finding carries a line anchor there is no review to carry the event: post each on its own and report the verdict as not set. On GitLab there is no batch: run one `reply` per linked finding and one `comment` per other finding, keyed by finding number, with the anchor you recorded -- a line in the new version, a removed line, a whole file, or no file anchor.

The event follows the verdict table in `SKILL.md`, except for approve: the findings go up under `COMMENT` on GitHub and the approval is reported as waiting to be named, unless the request that started the run named it.

The body is the finding's heading without its `## [N]`, bolded, then its ask, its summary, and its example carried across verbatim from the report, in that order; the marker line under the heading stays in the file.

The number is how you say "post 2 and 5" and how a thread is keyed back to its finding; it means nothing to the people reading the PR, who never saw the report. So it travels as `<!-- pr-review:finding-<N> -->` on the body's first line, which both forges render as nothing while the API keeps it in the body verbatim.

````markdown
<!-- pr-review:finding-2 -->
**issue (blocking): `src/cart.ts:42`**

**The ask:** what should `cartTotal` return for an empty cart?

<the finding's summary, as written in the report, with its `<file>:<line>` references>

**Example:**

```ts
cartTotal({ items: [], coupon: "SAVE10" })
// -> { total: 0, average: NaN }
```
````

Mark the file per finding individually -- a finding is `(posted <YYYY-MM-DD>, thread <id>)` only against its own success, and that id is how a follow-up run finds the thread again. A linked reply records the thread it joined. A batched review returns the review id and not the per-comment ids, so run `thread-list` afterwards and key each thread to its finding by the `<!-- pr-review:finding-<N> -->` marker its body carries. Neither forge guards against a double-post on an anchored comment, so a result you cannot match to a finding is checked with `thread-list` before anything is retried.

**Number visibility violation:** a finding number reaching the rendered text of anything posted -- a comment body or a thread reply -- rather than living only inside the marker. A body opening ``**issue (blocking): `src/handler.go:44`** [2]`` is a violation, and so is a reply opening "as finding 3 noted"; that same body under `<!-- pr-review:finding-2 -->`, and a reply naming the other point by what it says rather than by its number, are acceptable.

## Follow Up

Run `thread-list` and resolve every thread against the report, Resolved entries included: by the id recorded beside a finding, or where none was recorded -- a review posted before ids were kept -- by the `<!-- pr-review:finding-<N> -->` marker its body carries, or by its heading and ask where the marker is absent, since a review may predate it and some Markdown pipelines strip HTML comments -- a report written before findings carried an ask matches on its heading alone. A thread matching none of the three belongs to someone else and is reported as context, never answered as though it were yours; in a thread a finding joined as a reply, what came before that reply is context too, and only what came after it is answered; a match that fits two findings is reported as ambiguous rather than assigned to either.

Report each active finding's thread as replied, unresolved, or resolved, quoting what came back. Resolution state is not uniform: GitLab reports it, and GitHub's comment listing does not carry it, so say the state is unavailable rather than inferring it from a reply.

Then do the work the reply asks for. A reply pointing at code is checked against that code in the worktree before answering, and cited back by `<file>:<line>` the way a finding cites, so an author who says the deadline comes from the handler gets a response naming the handler's own lines; the investigation obligation is the same one the review ran under, and a reply the repository settles is answered rather than deferred. A finding the reply resolves moves to Resolved as `Settled in thread <id>.`, keeping its number, and is recommended for resolution. A reply holds to two sentences, with any code block uncounted, and keeps the finding's voice. The author is mid-thread and reading on a phone as often as not.

Replies post only on a request naming which threads to answer, one `reply` per thread id. Never resolve, unresolve, or delete a thread: resolution is the author's signal that they acted on it, and closing it here erases the record that anyone disagreed.
