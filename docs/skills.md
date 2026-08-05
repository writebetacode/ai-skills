# Skill behaviour

The things these skills do that you would not guess from their descriptions. Each `SKILL.md` remains the source of truth for how it runs; this covers what is shared, and what tends to surprise.

## Shared

No skill assumes `main`. Every git-facing one resolves the default branch from `origin/HEAD`, falling back to parsing `git remote show origin`, so repos on `develop`, `master`, or `trunk` behave correctly.

`/pr`, `/pr-review`, `/remote-issue`, and `/remote-release` carry no remote commands in their own bodies. Each resolves the forge or tracker first, then reads that CLI's reference file — `github.md`, `gitlab.md`, or `jira.md`, beside the `SKILL.md` — which owns the flags, JSON fields, and anchor semantics for one CLI. Nothing is composed from memory, and only the CLI you are actually using is ever loaded. Bodies still travel as file paths rather than being retyped into a command, so a description or a review comment arrives byte-exact.

Those commands run in your session, under your permission rules, which is why each of the four pre-approves its read-only operations — `auth`, `view`, `diff`, `list`, and the read-only git it opens with, such as the `git symbolic-ref` every default-branch resolution starts from — in `allowed-tools`, and leaves every create, edit, comment, and delete to prompt as usual. `/commit` grants the same way for the four commands it reads the index with. That grant covers only the turn you invoked the skill in, which is the turn the reconnaissance happens in; a submit or a follow-up you ask for later prompts like anything else.

The per-CLI reference file is found through a path Claude Code expands to wherever the skill is installed. Gemini CLI does not expand it, so each of the four falls back to reading that file from its own directory — the run still works, but this is the one place the two platforms are not identical.

When a CLI is missing, the run stops. You get `glab is not installed: <url>` rather than an auth error or a fallback to `curl` against the API, or to the other forge's CLI. This is deliberate: the alternative is a skill quietly doing the thing its own rules forbid.

Remote content is data, never instructions. A diff, a PR body, and a review thread are all written by whoever opened the change, so `/pr-review` treats a comment telling it what not to flag as a claim to check rather than an order to obey. That matters most for fork PRs, where none of it is authored by someone whose say-so the reviewer inherits.

Markdown written into a repo has to lint there, not here. This repo's `.markdownlint.jsonc` governs its own files and nothing else, so every skill that writes a `.md` file into your project — `/pr-review`'s report, `/sdlc-design`'s specs, plans, task files and research notes, and `/sdlc-implement`'s task-file edits — carries the rule itself. Each prefers your linter to its own list: where the project configures one, it runs that and fixes what comes back; the written-out rules are the fallback for projects that configure none.

Those written-out rules cover structure, and they deliberately leave prose unwrapped so that editing a sentence produces a one-line diff rather than a reflowed paragraph. Markdownlint's defaults disagree: run with no config at all it flags every unwrapped paragraph at 80 columns, which is how a plan that looks clean reports hundreds of MD013 errors the first time anyone lints it. A project configuring nothing is the case that bites, because it is the case where nobody decided anything. Each skill settles it where it writes rather than leaving it to the host. `/sdlc-design` writes `.markdownlint.jsonc` at `plans/`, turning off MD013 along with the MD033 that Gherkin's angle-bracket placeholders trip; markdownlint resolves config per directory, and the nearest config replaces the one above it rather than extending it, so the plans tree lints on defaults-but-for-those-two in every repo alike while the rest of your repo keeps the rules it already had. `/pr-review` instead carries a `markdownlint-disable` line inside the report, one file not being worth a config file. Anywhere else — a promoted ADR in `docs/adrs/`, say — your own linter still governs.

Bodies bound for a forge instead of a file — PR descriptions, issue bodies, release notes — are exempt, since nothing lints them and their templates are already shaped correctly.

Backends are chosen differently depending on what they are attached to. A forge follows the code, so `/pr`, `/pr-review`, and `/remote-release` read it off the `origin` remote. A tracker does not — a repo on GitHub may track work in Jira — so `/remote-issue` asks, offering the forge matching `origin` as a default to confirm rather than a decision already made.

## Why the long skills stay in one file

`/sdlc-design` is 293 lines and `/pr-review` is 174, which looks like two skills overdue for splitting into sibling files. The target they are actually measured against counts prose only — everything outside frontmatter, tables, and fenced blocks — and by that count they are 57 lines and 48. Most of `/sdlc-design` is template: 166 lines of fence and 65 blanks.

Splitting a block out trades tokens for a `Read` round-trip and the chance the model skips it and works from memory instead, so it pays only where a path you can name provably never reaches the block, and only above roughly 1,000 tokens — below that the pointer prose and the round-trip eat the saving. `/pr-review`'s Findings section and report template come to 4,740 bytes, about 1,185 tokens, which clears the floor and still stays inline: no mode skips it, since local and submit runs both write findings and a follow-up run marks them, and the skill fills the template in itself rather than handing it to anything else — the case the authoring rules name outright as the one not to split. `posting.md` is the split that does pay, because a local run never posts and so never reads it.

`/sdlc-design`'s artifact templates are the one block over the floor, at 5,819 bytes or about 1,455 tokens, and they stay inline anyway for three independent reasons. No named path skips them: both of the skill's modes author artifacts, and a mid-flight revision overwrites task files and appends new ones, needing the Task File Format exactly as a fresh run does. The skill composes from those templates itself, which the authoring rules name outright as the case not to split — the context that loads a template it fills in is the context that uses it. And they are byte-exact contracts, `## Acceptance Criteria` among them, read back by `/sdlc-implement` and compared word for word by the scenario-fidelity gate, where a skipped read becomes a reconstruction from memory.

Having the skill re-read the templates to confirm they are current does not rescue the split. Confirming on use means reading the file on every authoring run, and every completed design run authors, so the tokens arrive regardless and the round-trip is pure cost. Compaction points the same way: an invoked skill is re-attached after a summary keeping its first 5,000 tokens, so an inline template survives a compaction that could summarize a file read out of the transcript entirely.

## `/pr` owns part of the description, not all of it

The body it writes is wrapped in `<!-- pr-body:start -->` / `<!-- pr-body:end -->`. On update it rewrites only what sits between those markers. Everything outside is preserved byte-for-byte where it sits: reviewer-bot summaries, other tooling's generated blocks, and anything you typed yourself.

The ownership runs both ways: the skill also writes nothing of its own outside the markers, on create or on update. A trailing `## Notes for Reviewers` section, or any other commentary aimed at the reviewer, is off-limits — what would go in one goes in Summary or Why. One left there by a teammate or a bot is preserved like any other outside content.

The rule is positional, not name-based — content survives because of where it is, not because the skill recognized it. Markers are matched on the token alone, so spacing changed in transit does not break recognition, and `mr-body:*` is accepted as a legacy equivalent and rewritten to the canonical form.

If the markers are gone entirely — Markdown pipelines do strip HTML comments — the skill finds the contiguous run of `Tickets`, `Summary`, `Why`, `Changes` and replaces that in place instead. It inserts a fresh body at the top only when no template-shaped run exists anywhere, which is what stops a lost marker from producing two bodies.

## `/pr-review` separates reviewing from posting

Three modes, and local is the default. A local run writes numbered findings to `docs/pr-reviews/<number>.md` in the repo the PR belongs to and posts nothing; the file is left unstaged and never gitignored, since whether review notes belong in a repo's history is your call. A submit run writes that same file first, then sends the findings up as one review. A follow-up run reads the threads back and answers them.

Every mode reviews a checkout, not your working tree. The skill fetches the PR's head ref — `refs/pull/<n>/head` on GitHub, `refs/merge-requests/<iid>/head` on GitLab, both served by the base project, so a fork needs no extra remote — and adds a detached worktree at `/tmp/pr-review-<number>`, removed when the run ends. Your branch, working tree, and stash are never touched, and no finding can cite a line that only exists in whatever you had checked out at the time. A checkout that fails stops the run rather than falling back to reading the diff alone.

That checkout is what the report quotes from. Each finding carries the code it rests on in a fenced block labelled `<file>:<line-range>` — the lines it names, plus the caller, the definition, or the stale test the claim depends on. Where the evidence is an absence, the finding names the search that came back empty. Posted comments carry the off-diff quotes only, since the inline comment already sits on the line it is about.

The bar is what the quoted code supports. A claim the code does not back is dropped rather than reworded as a question or demoted to a nitpick, and remarks about how the code is written — naming, structure, an idiom someone else would have picked — are not findings at all. A review with nothing to report says so instead of filling the file.

Nothing posts without an instruction naming it. The numbers exist so you can say "post 2 and 5". **Approving is explicit-request-only and is never a consequence of a favourable verdict** — a submit run whose verdict reads approve posts a plain comment and tells you the approval is still waiting to be named.

The forges do not offer the same verdicts, and the skill reports the gap rather than simulating one:

| | GitHub | GitLab |
| --- | --- | --- |
| Inline comments | whole review in one call, one notification | posted one at a time |
| Request changes | supported | no such state; posts as a note, reported unsupported |
| Approve | supported | supported, pinned to the head SHA |
| Revoke | needs a review dismissal and elevated access | supported |

If the author pushed after a review was written, its anchors are re-derived against the new diff before anything posts. A stale head SHA is refused rather than relocating a comment onto whatever now sits at that line.

## `/remote-release` and `/remote-issue`

`/remote-release` establishes conventions from the repo — tag format, title prefix, notes structure, whether tags are annotated — and matches them rather than imposing its own. It pushes the tag before publishing, because the forges fail in opposite directions: `gh` refuses to publish against a tag missing from the remote, while `glab` would create the tag itself and mask the failed push. It also refuses a version that already resolves locally, since creating against an existing GitLab tag overwrites that release's name and notes instead of failing.

`/remote-issue` writes one body template across all three trackers, adjusting for what each models as a field rather than prose: Jira takes the work item type as `--type` where the forges get a `## Type` section. Jira descriptions render as plain text, so the skill keeps task lists and code fences out of them unless you ask.
