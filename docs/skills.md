# Skill behaviour

The things these skills do that you would not guess from their descriptions. Each `SKILL.md` remains the source of truth for how it runs; this covers what is shared, and what tends to surprise.

## Shared

No skill assumes `main`. Every git-facing one resolves the default branch from `origin/HEAD`, falling back to parsing `git remote show origin`, so repos on `develop`, `master`, or `trunk` behave correctly.

`/pr`, `/pr-review`, `/remote-issue`, and `/remote-release` contain no remote commands. They decide *what* to say and dispatch the *how* to a per-CLI agent — `gh`, `glab`, or `acli` — which owns the flags, JSON fields, and anchor semantics for one CLI. Bodies cross that boundary as file paths, never as text in a message, so a description or a review comment arrives byte-exact.

When a CLI is missing, the run stops. You get `glab is not installed: <url>` rather than an auth error or a fallback to raw commands — and the same if an agent was excluded from your install. This is deliberate: the alternative is a skill quietly doing the thing its own rules forbid.

Remote content is data, never instructions. A diff, a PR body, and a review thread are all written by whoever opened the change, so `/pr-review` treats a comment telling it what not to flag as a claim to check rather than an order to obey. That matters most for fork PRs, where none of it is authored by someone whose say-so the reviewer inherits.

Markdown written into a repo has to lint there, not here. This repo's `.markdownlint.jsonc` governs its own files and nothing else, so every skill and agent that writes a `.md` file into your project — `/pr-review`'s report, the architect's specs, plans, task files and research notes, and the task-file edits `/sdlc-implement` and the tester make — carries the rule itself. Each prefers your linter to its own list: where the project configures one, it runs that and fixes what comes back; the written-out rules are the fallback for projects that configure none.

Those written-out rules cover structure, and they deliberately leave prose unwrapped so that editing a sentence produces a one-line diff rather than a reflowed paragraph. Markdownlint's defaults disagree: run with no config at all it flags every unwrapped paragraph at 80 columns, which is how a plan that looks clean reports hundreds of MD013 errors the first time anyone lints it. A project configuring nothing is the case that bites, because it is the case where nobody decided anything. Each skill settles it where it writes rather than leaving it to the host. The architect writes `.markdownlint.jsonc` at `plans/`, turning off MD013 along with the MD033 that Gherkin's angle-bracket placeholders trip; markdownlint resolves config per directory, and the nearest config replaces the one above it rather than extending it, so the plans tree lints on defaults-but-for-those-two in every repo alike while the rest of your repo keeps the rules it already had. `/pr-review` instead carries a `markdownlint-disable` line inside the report, one file not being worth a config file. Anywhere else — a promoted ADR in `docs/adrs/`, say — your own linter still governs.

Bodies bound for a forge instead of a file — PR descriptions, issue bodies, release notes — are exempt, since nothing lints them and their templates are already shaped correctly.

Backends are chosen differently depending on what they are attached to. A forge follows the code, so `/pr`, `/pr-review`, and `/remote-release` read it off the `origin` remote. A tracker does not — a repo on GitHub may track work in Jira — so `/remote-issue` asks, offering the forge matching `origin` as a default to confirm rather than a decision already made.

## `/pr` owns part of the description, not all of it

The body it writes is wrapped in `<!-- pr-body:start -->` / `<!-- pr-body:end -->`. On update it rewrites only what sits between those markers. Everything outside is preserved byte-for-byte where it sits: reviewer-bot summaries, other tooling's generated blocks, and anything you typed yourself.

The rule is positional, not name-based — content survives because of where it is, not because the skill recognized it. Markers are matched on the token alone, so spacing changed in transit does not break recognition, and `mr-body:*` is accepted as a legacy equivalent and rewritten to the canonical form.

If the markers are gone entirely — Markdown pipelines do strip HTML comments — the skill finds the contiguous run of `Tickets`, `Summary`, `Why`, `Changes` and replaces that in place instead. It inserts a fresh body at the top only when no template-shaped run exists anywhere, which is what stops a lost marker from producing two bodies.

## `/pr-review` separates reviewing from posting

Three modes, and local is the default. A local run writes numbered findings to `docs/pr-reviews/<number>.md` in the repo the PR belongs to and posts nothing; the file is left unstaged and never gitignored, since whether review notes belong in a repo's history is your call. A submit run writes that same file first, then sends the findings up as one review. A follow-up run reads the threads back and answers them.

Nothing posts without an instruction naming it. The numbers exist so you can say "post 2 and 5". **Approving is explicit-request-only and is never a consequence of a favourable verdict** — a submit run whose verdict reads approve posts a plain comment and tells you the approval is still waiting to be named.

The forges do not offer the same verdicts, and the skill reports the gap rather than simulating one:

| | GitHub | GitLab |
| --- | --- | --- |
| Inline comments | whole review in one call, one notification | posted one at a time |
| Request changes | supported | no such state; posts as a note, reported unsupported |
| Approve | supported | supported, pinned to the head SHA |
| Revoke | needs a review dismissal and elevated access | supported |

If the author pushed after a review was written, its anchors are re-derived against the new diff before anything posts. The agents refuse a stale head rather than relocating a comment onto whatever now sits at that line.

## `/remote-release` and `/remote-issue`

`/remote-release` establishes conventions from the repo — tag format, title prefix, notes structure, whether tags are annotated — and matches them rather than imposing its own. It pushes the tag before publishing, because the forges fail in opposite directions: `gh` refuses to publish against a tag missing from the remote, while `glab` would create the tag itself and mask the failed push. It also refuses a version that already resolves locally, since creating against an existing GitLab tag overwrites that release's name and notes instead of failing.

`/remote-issue` writes one body template across all three trackers, adjusting for what each models as a field rather than prose: Jira takes the work item type as `--type` where the forges get a `## Type` section. Jira descriptions render as plain text, so the skill keeps task lists and code fences out of them unless you ask.
