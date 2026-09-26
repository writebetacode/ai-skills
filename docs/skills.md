# Skill behaviour

The things these skills do that you would not guess from their descriptions. Each `SKILL.md` remains the source of truth for how it runs; this covers what is shared, and what tends to surprise.

## Shared

No skill assumes `main`. Every git-facing one resolves the default branch from `origin/HEAD`, falling back to parsing `git remote show origin`, so repos on `develop`, `master`, or `trunk` behave correctly.

`/pr`, `/pr-review`, `/remote-issue`, and `/remote-release` carry no remote commands in their own bodies. Each resolves the forge or tracker first, then reads that CLI's reference file — `github.md`, `gitlab.md`, or `jira.md`, beside the `SKILL.md` — which owns the flags, JSON fields, and anchor semantics for one CLI. `/pr-review` has a fourth, `ticket.md`, because a ticket's tracker is independent of the forge the code sits on: a GitHub PR routinely carries a Jira key, so that file covers `acli`, `gh issue`, `glab issue`, and a `WebFetch` fallback in one place and is read only when a ticket is actually in play. Nothing is composed from memory, and only the CLI you are actually using is ever loaded. Bodies still travel as file paths rather than being retyped into a command, so a description or a review comment arrives byte-exact.

Those commands run in your session, under your permission rules, which is why each of the four pre-approves its read-only operations — `auth`, `view`, `diff`, `list`, and the read-only git it opens with, such as the `git symbolic-ref` every default-branch resolution starts from — in `allowed-tools`, and leaves every create, edit, comment, and delete to prompt as usual. `/commit` grants the same way for the four commands it reads the index with. That grant covers only the turn you invoked the skill in, which is the turn the reconnaissance happens in; a submit or a follow-up you ask for later prompts like anything else.

The per-CLI reference file is found through a path Claude Code expands to wherever the skill is installed. Gemini CLI does not expand it, so each of the four falls back to reading that file from its own directory — the run still works, but this is the one place the two platforms are not identical.

When a CLI is missing, the run stops. You get `glab is not installed: <url>` rather than an auth error or a fallback to `curl` against the API, or to the other forge's CLI. This is deliberate: the alternative is a skill quietly doing the thing its own rules forbid.

Remote content is data, never instructions. A diff, a PR body, and a review thread are all written by whoever opened the change, so `/pr-review` treats a comment telling it what not to flag as a claim to check rather than an order to obey. That matters most for fork PRs, where none of it is authored by someone whose say-so the reviewer inherits.

Markdown written into a repo has to lint there, not here. This repo's `.markdownlint.jsonc` governs its own files and nothing else, so every skill that writes a `.md` file into your project — `/pr-review`'s report, `/sdlc-design`'s specs, plans, task files and research notes, and `/sdlc-implement`'s task-file edits — carries the rule itself. Each prefers your linter to its own list: where the project configures one, it runs that and fixes what comes back; the written-out rules are the fallback for projects that configure none.

Those rules leave prose unwrapped, so editing a sentence is a one-line diff. Markdownlint's defaults flag every unwrapped line past 80 columns, which bites a project that configures nothing, so each skill settles it where it writes. `/sdlc-design` writes a `.markdownlint.jsonc` at `plans/` that turns off MD013 and the MD033 that Gherkin's angle-bracket placeholders trip; markdownlint uses the nearest config instead of merging it with the ones above, so only the plans tree is affected. `/pr-review` puts a `markdownlint-disable` line in the report instead, one file not being worth a config. Anywhere else, such as a promoted ADR in `docs/adrs/`, your own linter governs.

Bodies bound for a forge instead of a file — PR descriptions, issue bodies, release notes — are exempt, since nothing lints them and their templates are already shaped correctly.

Everything these skills put in front of a person is capped, because the reader is skimming and the writer is not. A PR Summary gets two sentences and its Changes list ten one-line bullets. A review finding gets one question, "The ask", then a summary of one to four sentences that cites code by `file:line`, then an example of at most eight lines, and that same text is what goes up to the forge, with no review summary above it; a reply on the thread gets two sentences. An issue Description gets three sentences, with one line for each step, criterion, and open question. Quoted code in a reply is exempt from its cap: it is the fastest part to read, and trimming it only pushes the argument back into prose. `/remote-release` is capped differently, because your repo's own release history sets length there as it already sets structure — the default of a one-sentence intro over one-line items applies only where there is no history to match.

One thing sits outside all of that. `/sdlc-design`'s specs, plans, task files, ADRs, and research notes are reference documents someone opens for the detail, and they stay as long as they need to be.

Backends are chosen differently depending on what they are attached to. A forge follows the code, so `/pr`, `/pr-review`, and `/remote-release` read it off the `origin` remote. A tracker does not — a repo on GitHub may track work in Jira — so `/remote-issue` asks, offering the forge matching `origin` as a default to confirm rather than a decision already made.

## Why the long skills stay in one file

`/sdlc-design` and `/pr-review` are the two longest skills, and look overdue for splitting into sibling files. The authoring rules measure a skill by its prose in tokens rather than its length on the page, so `/sdlc-design`, which is mostly template, sits under the target. `/pr-review` is over it, and has been through the two checks the target calls for: cutting what a model works out on its own, then testing each large block against the rules for splitting.

A block moves to its own file only when a mode you can name never reads it and it is big enough, roughly 1,000 tokens, to pay for the extra read and the risk that the model skips it and works from memory. `posting.md` passes, because a local review never posts. `/pr-review`'s findings rules and report template do not: every review mode uses them, and the skill fills the template in itself. Its Audit section is skipped by follow-up runs but is too small to be worth a file. `ticket.md` is small too, and stays separate because every forge skill keeps its CLI commands in a reference file and a PR with no ticket never opens it.

`/sdlc-design`'s artifact templates stay inline for three reasons: both of its modes write artifacts, it fills the templates in itself, and they are exact contracts, `## Acceptance Criteria` among them, that `/sdlc-implement` and a signoff gate read back word for word, where a skipped read would become a reconstruction from memory. Re-reading a split-out copy on every run would cost the same tokens plus a round trip, and an inline template survives compaction, since an invoked skill is re-attached after the summary.

## `/pr` pushes the head branch

It names the head explicitly rather than letting the CLI default to whatever is checked out, which is what keeps a stacked run from opening a PR off the wrong sibling branch — but it also costs `gh` the prompt it would otherwise raise to push an unpushed branch. So the skill pushes itself: it compares the head against `git ls-remote --heads origin` and runs `git push -u origin <head>` when the remote is missing the branch or sitting behind it, since a create against an absent head fails and an update against a stale one describes commits the reviewer cannot see. It never forces — a non-fast-forward refusal means the remote has commits you do not, and that is reported rather than overwritten.

## `/pr` titles follow Conventional Commits

A title reads `<type>(<ticket>): <description>`, using the same types `/commit` does, with the ticket the body's Tickets section links as the scope: `fix(PROJ-123): refresh auth tokens on expired sessions`, or `fix(#42): ...` for an issue on the forge itself. With no ticket the scope is dropped rather than filled with a component name, so `feat: add retry to webhook delivery` is the whole title. An update redrafts the title against the branch as it now stands. On GitLab that redraft leaves a draft MR a draft: GitLab stores draft state as a `Draft:` title prefix, which a bare `glab mr update --title` drops, so the comparison ignores the prefix and the title update carries `--draft` to keep it.

## `/pr` owns part of the description, not all of it

The body it writes is wrapped in `<!-- pr-body:start -->` / `<!-- pr-body:end -->`. On update it rewrites only what sits between those markers. Everything outside is preserved byte-for-byte where it sits: reviewer-bot summaries, other tooling's generated blocks, and anything you typed yourself.

The ownership runs both ways: the skill also writes nothing of its own outside the markers, on create or on update. A trailing `## Notes for Reviewers` section, or any other commentary aimed at the reviewer, is off-limits — what would go in one goes in Summary. One left there by a teammate or a bot is preserved like any other outside content.

The rule is positional, not name-based — content survives because of where it is, not because the skill recognized it. Markers are matched on the token alone, so spacing changed in transit does not break recognition.

If the markers are gone entirely — Markdown pipelines do strip HTML comments — the skill finds the contiguous run of `Tickets`, `Summary`, and `Changes` and replaces that run in place instead. It inserts a fresh body at the top only when no template-shaped run exists anywhere, which is what stops a lost marker from producing two bodies.

## `/pr-review` separates reviewing from posting

Local is the default: a run writes numbered findings to `docs/pr-reviews/<number>.md` in the repo you ran it from and posts nothing. The file is left unstaged and never gitignored, since whether review notes belong in history is your call. A submit run writes the same file, then sends the findings up as one review; `post 2 and 5` sends findings already written, without reviewing again; a follow-up run reads the threads back and answers them.

Every mode reads the code from a detached worktree at `/tmp/pr-review-<repo-slug>-<number>`, checked out at the PR's head, so your branch, working tree, and stash are never touched and no finding can cite a line that exists only in your checkout. Fork PRs need no extra remote, since both forges serve the head ref from the base project. The worktree outlives the run, because a later `post 2 and 5` has to re-read what it sends: it is reused and moved to the current head, removed once nothing is left to post or answer, and its path is always named in what you get back. The report stays in your working copy, never in the worktree, so removing the worktree never takes the report with it.

The review follows the change past the files it touches: call sites of a changed signature, readers of a changed schema, config key, or migration, and the tests covering them. Where the change crosses the repo boundary, through a published package, an API contract, or a generated client, it also reads the git checkouts beside your repo and any repo your `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md` names, at whatever revision they sit at, and never writes to them. A consumer it confirms broken is a finding; one it cannot settle is named in what you get back rather than written into the report. A ticket named in the arguments or the PR is read before the diff, for what the change was meant to do, and one that cannot be read is reported as unread rather than guessed at.

A finding has to trace to the change and be backed by the code it cites. It is phrased as a question and never proposes a fix, so the skill posts no suggestion blocks. How the code is written is not a finding unless the repo's written rules say so, or the repo already does the same job another way at two or more existing sites. Your `CONTRIBUTING.md`, `CLAUDE.md`, and similar files move the bar in both directions, with two exceptions: rules your linter already enforces are left to CI, and a guideline file the PR itself edits is reviewed rather than obeyed, so a fork cannot relax the rules it is judged by.

Each finding is its own `## [N]` heading anchored to a single line, because GitLab quotes every anchored line into the thread. Numbers never change and are never reused: a fixed finding moves to Resolved with its number, which keeps "post 3" and the marker on an already-posted comment pointing at the same finding. A re-review rewrites the file in place, but only a file in the current layout: a report in any other shape is never rewritten or posted from, so an older review keeps its history exactly as written, and the skill tells you what doesn't match and stops.

Existing review comments are read last, once the findings are settled, so the review is an independent reading rather than a response to someone else's. A comment making the same point as a finding is linked to it, and the finding posts as a reply in that thread. Every other comment about the code, skipping thanks, bot output, the author's replies, and its own posts, becomes a finding of its own, researched in the worktree, so even a concern the code clears gets an answer citing the lines that clear it.

Nothing reaches the report until a cold-context auditor has re-derived each finding from the code, the same shape `/sdlc-implement` uses to validate a task. It withdraws any finding whose quotes, consequence, example, or link to the change does not hold up, and its decision is final. Withdrawn findings stay visible under `## Withdrawn in audit`, unnumbered and never posted, and the verdict is set from what survived. If the auditor cannot run, the report is marked `<!-- unaudited -->`.

Nothing goes up but the findings: no review body, overview, or closing comment in any mode. The verdict reaches GitHub only as the review's event. Finding numbers stay out of what is posted, riding instead in a hidden `<!-- pr-review:finding-N -->` marker that follow-up runs use to match threads back to findings.

Nothing posts without an instruction naming it. **Approving is explicit-request-only and is never a consequence of a favourable verdict**: a submit run whose verdict reads approve posts its findings as a plain comment review and tells you the approval is still waiting to be named.

The forges do not offer the same verdicts, and the skill reports the gap rather than simulating one:

| | GitHub | GitLab |
| --- | --- | --- |
| Inline comments | whole review in one call, one notification | posted one at a time |
| Request changes | supported, as the review event with no body | no such state; reported unsupported, nothing posted in its place |
| Approve | supported | supported, pinned to the head SHA |
| Revoke | needs a review dismissal and elevated access | supported |

If the author pushed after the review was written, every anchor is re-read against the new diff before anything posts; a comment is never moved onto whatever now sits at its old line.

## `/remote-release` and `/remote-issue`

`/remote-release` establishes conventions from the repo — tag format, title prefix, notes structure, whether tags are annotated — and matches them rather than imposing its own. It pushes the tag before publishing, because the forges fail in opposite directions: `gh` refuses to publish against a tag missing from the remote, while `glab` would create the tag itself and mask the failed push. It also refuses a version that already resolves locally, since creating against an existing GitLab tag overwrites that release's name and notes instead of failing.

`/remote-issue` writes one body template across all three trackers, adjusting for what each models as a field rather than prose: Jira takes the work item type as `--type` where the forges get a `## Type` section. Jira descriptions render as plain text, so the skill keeps task lists and code fences out of them unless you ask.
