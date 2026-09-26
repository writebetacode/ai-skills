# Submitting and Following Up

Read this when entering submit or follow-up mode from the Workflow in `SKILL.md`. `SKILL.md` and the host's `github.md` or `gitlab.md` are already loaded.

## Submit

A submit run sends every active finding. A later request naming findings ("post 2 and 5", "send the blocking ones") sends only those. If the selection is ambiguous, ask before sending anything. What gets posted is the findings, one comment each, plus the Verdict as the review event on GitHub, and nothing else. A finding marked `(linked to thread <id>)` (or the older `(also raised in thread <id>)`) is posted as a `reply` in that thread, with the same body a new comment would have. A finding marked `(linked to comment <url>)` posts as an ordinary comment, since its summary already points back to that comment.

First compare the SHA on the report's `Reviewed at` line with the current head. If they differ, the author has pushed since. Move the worktree to the new head and re-read every anchor, reference, and example against the new diff before posting. Never post against a stale head by moving a comment onto whatever is now at that line.

On GitHub the review is one `review-batch` call carrying the head SHA, the event, and one entry per anchored finding, with no review body, so it arrives as one notification and lands whole or not at all. Unanchored and linked findings can't go in that array (every entry needs a path and a line, and none can name a thread). Once the review has landed, post each of them separately: an unanchored finding as a `comment` with no file anchor, a linked one as a `reply`. If the review was rejected, post none of them. If no finding has a line anchor, there's no review to carry the event: post each separately and report the verdict as not set. On GitLab there is no batch: run one `reply` per linked finding and one `comment` per other finding, using the recorded anchor (a line in the new version, a removed line, a whole file, or no file anchor).

The event follows the verdict table in `SKILL.md`, except for approve. Unless the request that started the run named approval, post the findings under `COMMENT` on GitHub and report the approval as waiting for the user to ask for it.

The body is the finding's heading without `## [N]`, in bold, then its ask, summary, and example, copied word for word from the report in that order. The marker line under the heading stays in the file.

The finding number means nothing to people reading the PR, so it only goes in `<!-- pr-review:finding-<N> -->` on the body's first line. Both forges hide it when rendering and keep it in the API body.

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

Mark the file per finding: `(posted <YYYY-MM-DD>, thread <id>)` only for a finding that actually posted. A follow-up run uses that id to find the thread. A linked reply records the thread it joined. A batched review returns the review id but not each comment's id, so run `thread-list` afterwards and match threads to findings by the `<!-- pr-review:finding-<N> -->` marker. Neither forge prevents double-posting an anchored comment, so if you can't match a result to a finding, check `thread-list` before retrying anything.

**Number visibility violation:** a finding number appearing in the visible text of anything posted, a comment body or a thread reply, instead of only inside the marker. A body opening ``**issue (blocking): `src/handler.go:44`** [2]`` is a violation, and so is a reply opening "as finding 3 noted". The same body under `<!-- pr-review:finding-2 -->`, and a reply that refers to the other point by what it says, are acceptable.

## Follow Up

Run `thread-list` and match every thread against the report, Resolved entries included. Match first by the id recorded next to a finding. If none was recorded (a review posted before ids were kept), match by the `<!-- pr-review:finding-<N> -->` marker in its body, and if the marker is missing (older reviews, or Markdown pipelines that strip HTML comments), by its heading and ask. A report from before findings had an ask matches on heading alone. A thread that matches nothing belongs to someone else: report it as context and never answer it as if it were yours. In a thread a finding joined as a reply, everything before that reply is context, and only what came after is answered. If a thread matches two findings, report it as ambiguous and don't assign it.

Report each active finding's thread as replied, unresolved, or resolved, quoting the reply. GitLab reports resolution state, but GitHub's comment listing doesn't. On GitHub, say the state is unavailable instead of guessing it from a reply.

Then do the work each reply asks for. If a reply points at code, check that code in the worktree before answering and cite it by `<file>:<line>`, so an author who says the deadline comes from the handler gets an answer naming the handler's lines. Answer replies the repository settles instead of putting them off. When a reply resolves a finding, move it to Resolved as `Settled in thread <id>.`, keeping its number, and recommend resolving the thread. Keep a reply to two sentences, not counting any code block, in the finding's voice. The author is often reading on a phone.

Post replies only when a request names which threads to answer, one `reply` per thread id. Never resolve, unresolve, or delete a thread. Resolution is the author's signal that they acted, and closing it here erases the record that anyone disagreed.
