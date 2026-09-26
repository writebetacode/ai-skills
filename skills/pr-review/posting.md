# Submitting and Following Up

Read on entering submit, post-named, or follow-up mode from `SKILL.md`'s Review section. `SKILL.md` and the host's `github.md` or `gitlab.md` are already loaded.

## Submit

**What goes up.** A submit run sends every active finding; a request naming findings ("post 2 and 5", "send the blocking ones") sends only those, asking first if the selection is ambiguous. Only the findings post, one comment each, plus the Verdict as the review event on GitHub.

- `(linked to thread <id>)`: post as a `reply` in that thread, same body as a new comment.
- `(linked to comment <url>)`: post as an ordinary comment; its summary already points back.

**Stale head.** Compare the `Reviewed at` SHA with the current head first. If they differ, move the worktree to the new head and re-read every anchor, reference, and example against the new diff before posting. Never post against a stale head by moving a comment onto whatever now sits at that line.

**GitHub.** One `review-batch` call carries the head SHA, the event, and one entry per anchored finding, with no review body, so it lands as one notification, whole or not at all. Entries need a path and a line and can't name a thread, so once the review lands, post the rest separately: unanchored findings as a `comment` with no file anchor, linked ones as a `reply`. If the review was rejected, post none of them. If no finding has a line anchor, there's no review to carry the event: post each separately and report the verdict as not set.

**GitLab.** No batch: one `reply` per linked finding and one `comment` per other finding, with the recorded anchor (new-version line, removed line, whole file, or none).

**Event.** Follows `SKILL.md`'s verdict table, except approve: unless the request that started the run named approval, post under `COMMENT` on GitHub and report the approval as waiting to be asked for.

**Body.** The finding's heading without `## [N]`, in bold, then its ask, summary, and example copied verbatim from the report. The marker line stays in the file. The number means nothing to PR readers, so it rides only in `<!-- pr-review:finding-<N> -->` on the first line, which both forges hide when rendering and keep in the API body.

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

**Recording.** Mark each finding `(posted <YYYY-MM-DD>, thread <id>)` only on its own success; follow-up runs find threads by that id. A linked reply records the thread it joined. A batched review returns only the review id, so run `thread-list` afterwards and match threads to findings by their marker. Neither forge prevents double-posting an anchored comment, so check `thread-list` before retrying anything you can't match.

**Number visibility violation:** a finding number in the visible text of a posted comment or reply instead of only inside the marker. A body opening ``**issue (blocking): `src/handler.go:44`** [2]`` is a violation, as is a reply opening "as finding 3 noted"; the same body under `<!-- pr-review:finding-2 -->`, and a reply naming the other point by what it says, are acceptable.

## Follow Up

Run `thread-list` and match every thread against the report, Resolved entries included, trying in order:

1. the id recorded beside a finding;
2. the `<!-- pr-review:finding-<N> -->` marker in its body (some Markdown pipelines strip it);
3. its heading and ask.

A thread matching nothing belongs to someone else: report it as context, never answer it. In a thread a finding joined as a reply, only what came after that reply is answered; earlier posts are context. A thread matching two findings is reported as ambiguous, not assigned.

Report each active finding's thread as replied, unresolved, or resolved, quoting the reply. GitLab reports resolution state; GitHub's listing doesn't, so say it's unavailable rather than guess.

Then do the work each reply asks for. Check code a reply points at in the worktree before answering, and cite it by `<file>:<line>`, so an author saying the deadline comes from the handler gets an answer naming the handler's lines. Answer what the repository settles rather than deferring it. A reply that resolves a finding moves it to Resolved as `Settled in thread <id>.`, number kept, with the thread recommended for resolution. Replies are at most two sentences, code blocks uncounted, in the finding's voice; the author is often on a phone.

Post replies only when a request names which threads to answer, one `reply` per thread id. Never resolve, unresolve, or delete a thread: resolution is the author's signal that they acted, and closing it erases the record that anyone disagreed.
