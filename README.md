# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`) for the settings merge.

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Symlinks all skills and agents into `~/.claude` and `~/.gemini` so repo updates apply immediately without reinstalling. A single set of skill files serves both platforms; agents are Claude Code only. `task install` runs `task uninstall` first, so it fully reconciles the installed state with your config on every run — newly excluded items are removed, newly re-included ones come back.

### Choosing what gets installed

Everything installs by default. To opt out of specific skills or agents, copy `config.example.yml` to `config.yml` (gitignored) and list the directory names you don't want:

```yaml
exclude:
  skills:
    - mr
    - gh-issue
  agents:
    - sdlc-tester

platforms:
  claude: true
  gemini: false      # skip a whole platform
```

Because it's an exclude list, a skill added to the repo later installs automatically unless you name it. Use block form for the lists — inline form (`skills: [mr]`) is rejected with an error rather than silently ignored.

`task verify` follows the same config: excluded items are checked to be *absent*, so a stale symlink from a previous install is reported as an error. `task install` removes those itself before linking — it deletes any symlink pointing into this repo whose name the repo no longer ships or that `config.yml` now excludes, so excluding a skill takes effect on the next install rather than leaving it live and competing at selection time. Symlinks pointing elsewhere and real files are never touched; those belong to someone else and are only reported, by `task doctor`.

The `deny` list blocks irreversible git operations outright — `reset --hard`, `clean -f`, `restore`, and force-push. Branch deletion (`git branch -d/-D`) sits in `ask` instead: rules are evaluated deny, then ask, then allow, so it prompts on every deletion even though `Bash(git branch *)` is allowed, and you approve inline rather than being blocked. That is deliberate — `/prune-branches` and `/sdlc-complete` already require per-branch confirmation, and the permission layer is what enforces it when a prompt-level rule is misread. `git worktree remove` sits in `ask` for the same reason, and `git stash clear`/`git stash drop` in `deny`: both discard work that no commit holds, so neither is recoverable through the reflog the way a bad `checkout` is.

`task install` also symlinks `claude/statusline.sh` into `~/.claude/` — before the merge below, so the `statusLine` command never points at a script that isn't there yet — and merges `claude/settings.json` into `~/.claude/settings.json`: the permission `allow`/`ask`/`deny` lists are unioned, and every other key takes the repo's value — the repo is the source of truth for the settings it defines, so local edits to those keys are overwritten on each install. `task uninstall` removes every symlink pointing into this repo and subtracts the repo-defined settings back out of `~/.claude/settings.json`: permission entries listed in the repo are removed from `allow`, `ask`, and `deny` alike (including any you happened to add independently — re-add those if needed), repo-defined keys are deleted, and everything the repo never defined survives untouched. The subtraction spans all three lists on purpose: an entry the repo moves between them — `deny` to `ask`, say — would otherwise leave its stale copy behind, and since rules evaluate deny before ask, the move would silently do nothing.

### Settings keys

Every key `claude/settings.json` defines, and why. Because the merge makes the repo the source of truth for the keys it names, these are imposed on each install rather than suggested — change them here, not in `~/.claude/settings.json`, or the next install reverts them.

| Key | Value | Min version | Why |
| --- | --- | --- | --- |
| `permissions` | see above | — | `defaultMode: auto`, plus the `allow`/`ask`/`deny` lists described earlier. |
| `effortLevel` | `high` | — | Standing default for multi-step work. `xhigh` exists but is better invoked per-task than left on. |
| `tui` | `fullscreen` | — | Flicker-free alt-screen renderer with virtualised scrollback; steadier on long runs than the classic main-screen one. |
| `askUserQuestionTimeout` | `10m` | 2.1.200 | Default is `never`, so an unanswered question blocks indefinitely. Ten minutes lets an unattended `/sdlc-implement` run continue with whatever was already selected. |
| `autoMemoryEnabled` | `false` | — | Default is `true`. Off here so session state stays out of the auto-memory directory and behaviour depends only on what is checked in. |
| `fileCheckpointingEnabled` | `true` | 2.1.119 | Already the default — set explicitly because it is the main recovery path in this repo, where `reset --hard`, `restore`, and `checkout --` are all denied. Pinning it means a global opt-out elsewhere cannot silently remove that safety net. |
| `showTurnDuration` | `true` | — | Per-turn timing, alongside the status line's context and rate-limit readouts. |
| `spinnerTipsEnabled` | `false` | — | The stock tips compete with the custom `spinnerVerbs` below. |
| `spinnerVerbs` | `replace` + list | — | Cosmetic. `replace` rather than `append` so only these appear. |
| `statusLine` | command | — | Registers `~/.claude/statusline.sh`; see below. |
| `enabledPlugins` | 6 official | — | context7 for library docs, four LSPs, and security-guidance. |
| `skipAutoPermissionPrompt` | `true` | — | Records that the auto-mode dialog was accepted, so `defaultMode: auto` does not re-prompt on a fresh machine. |
| `skipWorkflowUsageWarning` | `true` | — | Same idea for the multi-agent workflow usage warning. |

Only the two keys above carry a documented version floor; the rest are long-standing and unannotated in the [settings reference](https://code.claude.com/docs/en/settings). Everything here is verified against Claude Code 2.1.220. Two caveats worth knowing: `askUserQuestionTimeout` is read from user settings only — which is where `task install` writes, so it applies, but copying it into a project `.claude/settings.json` would silently do nothing — and `skipAutoPermissionPrompt` and `skipWorkflowUsageWarning` are acceptance flags rather than documented settings, so treat them as implementation detail.

### Status line

`claude/statusline.sh` is symlinked to `~/.claude/statusline.sh` and registered via the `statusLine` key, so edits in the repo take effect immediately with no reinstall. It renders:

```
ai-skills · ⎇ ABC-1 · Opus5·hi · ctx 33% 65k · 5h 12% ↻1.3h
```

Directory and git worktree, model and reasoning effort (`lo`/`md`/`hi`/`xh`), context window (percentage plus absolute tokens), and the 5-hour rate-limit window with a countdown to its reset. Percentages turn yellow at 50% and red at 80%, rounded so the colour never disagrees with the number beside it.

The line is built to fit 80 columns — or `$COLUMNS`, if the terminal exports it. Should it overrun — a long branch on a narrow terminal — the branch is truncated with an ellipsis, then dropped entirely if fewer than three characters would survive, and only then is the directory trimmed, to a floor of eight characters. The fixed-width segments are never sacrificed. Model and effort stay abbreviated (`Opus5·hi`) rather than spelled out, which keeps roughly nine columns in reserve for long branch names.

Reset countdowns always round *up*, to one decimal where the unit warrants it — `1.1h`, `1.1d` — because under-reporting time remaining is the costly direction. A trailing `.0` is dropped, so exact values stay compact (`2h`, `7d`), and the unit only changes at a full 1.0, so 23 hours reads `23h` rather than `0.9d`. Anything under a minute renders `<1m` instead of rounding up to `1m`, which would imply headroom that isn't there.

Every value comes from the JSON the harness pipes in on stdin — nothing is scraped or estimated. Segments whose fields are absent drop out silently rather than rendering placeholders: `rate_limits` is missing until the first API response of a session and for non-subscription auth, and `context_window.current_usage` is null immediately after `/compact`. `refreshInterval: 60` is set because the reset countdowns are time-based and the harness otherwise re-renders only on events, which would leave them stale while idle.

One limit worth knowing, a property of the data rather than the script: Fable 5 is metered against dollar-denominated usage credits rather than a percentage window, so no Fable figure can appear here at all. Use `/usage` and `/usage-credits` for that, and for the per-model breakdown the rate-limit fields do not carry.

Verification and teardown:

```bash
task uninstall                 # remove symlinks and subtract repo-defined settings
task verify                    # run every check below, in order
task verify:skills-installed   # check all symlinks
task verify:pr-body            # check the shared PR/MR body template has not drifted
task doctor                    # report installed skills/agents this repo does not manage
```

`task verify` runs the checks sequentially and stops at the first failure, so fix an early failure to see the later checks run.

`task doctor` runs last and is advisory — it never fails the build and never deletes anything. It reports two things `verify` cannot: `UNMANAGED` entries (a real file, or a symlink pointing outside this repo) that are live and compete with repo skills at selection time, and `EMPTY` leftover directories from an earlier layout of this repo, which are inert but look like installed skills until you look inside. `verify:skills-installed` only checks that expected entries exist, so neither shows up there. Remove anything you no longer want by hand.

The PR/MR body template is duplicated verbatim between `/pr` and `/mr` (skills load standalone — no include mechanism), marked with `<!-- pr-body:v1 -->` and checked by `task verify:pr-body`. The marker sits below the section heading, so `## PR Body Template` and `## MR Body Template` may differ while everything from the intro line through the closing fence stays byte-identical. Review artifacts read the same on both forges; edit both files and bump the marker together.

The template body is wrapped in `<!-- mr-body:start -->` / `<!-- mr-body:end -->` markers that both skills write into the PR or MR description. These delimit the region the skills own: on update they rewrite only what sits between the markers, and everything outside is preserved byte-for-byte in its original position — reviewer-bot summaries such as Cursor Bugbot's, other tooling's generated blocks, and hand-written additions all survive without the skills needing to recognize them. Descriptions predating the markers are migrated in place on the next update. The markers are shared rather than forge-specific so a PR body stays recognizable if the branch moves between forges.

## What's included

Skills live in `skills/` and are shared by both Claude Code and Gemini CLI. Every git-facing skill resolves the repo's default branch from `origin/HEAD` rather than assuming `main`, so they behave correctly on repos that default to `develop`, `master`, or `trunk`. None of them pin a model — each runs on whatever model your session is already using, so invoking a skill never silently changes tiers or costs. Agents are the opposite case and do pin one; see [Agents](#agents).

### Git, GitHub & GitLab

| Command | Description |
|---|---|
| `/commit` | Stage-aware conventional commits — commits exactly what is staged, immediately |
| `/pr` | Create or update GitHub pull requests with structured descriptions |
| `/mr` | Create or update GitLab merge requests with the same structured description, via `glab` |
| `/restack` | Rebase open branches onto the latest default branch, whether their base was squash-merged or the default branch simply moved ahead |
| `/prune-branches` | Delete local branches whose changes already landed in the default branch, including squash-merged branches `git branch -d` refuses as unmerged |
| `/gh-issue` | Create consistently-formatted GitHub issues with type, priority, and optional context sections |
| `/gh-release` | Tag the default branch and publish a GitHub release, inferring the version from commit history and drafting notes in the repo's established voice |

### Software Development Workflow

A manifest-driven process from feature idea to merged code. `/sdlc-design` is the single entry point: a persistent architect agent runs strict one-question-at-a-time intake and context7-backed research, authors all artifacts (spec, plan, tasks, MANIFEST), enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering, and handles mid-flight revisions via per-task keep/revise/void triage. Within an epic, tasks run linearly; across epics, disjoint dependency sets may run in parallel via two `/sdlc-implement` sessions in two checkouts.

`/sdlc-implement` runs a persistent tester and coder through a batched TDD loop — tester writes an AC group's red tests, coder greens them, later batches learn from earlier ones — with the coordinator relaying every handoff, since subagents can only message `main`. It gates each task on its epic's dependencies being `Complete` in the manifest. After lint and a full-suite pass, the coordinator (not the tester) spawns a fresh sub-agent as an unbiased third-party spec-vs-code validator; the task approves only when the validator reports no drift. Full mechanics live in the two SKILL.md files and the tester/coder AGENT.md files.

| Command | Phase | Description |
|---|---|---|
| `/sdlc-design` | 1 -- Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent; also handles mid-flight revisions via per-task keep/revise/void triage |
| `/sdlc-implement` | 2 -- Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, epic-precondition gate, and third-party spec-vs-code validation via a fresh sub-agent; auto-picks the next task from the manifest when called without arguments |
| `/sdlc-complete` | 3 -- Complete | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |

The commands share a common file layout under `plans/` (keep this directory out of version control in your global gitignore):

```
plans/
  <project-slug>/                   # project folder (from /sdlc-design, no date prefix)
    MANIFEST.md                     # central control document (always present)
    prd.md                          # optional -- WHAT users need (product requirements)
    adr.md                          # running log of project-level architecture decisions
    epics.md                        # epic list, dependency graph, and build order (multi-epic)
    research/<topic>.md             # architect's citation notes
    epics/
      NN-<epic-slug>/               # NN-prefix matches Build Order
        spec.md                     # technical specification
        plan.md                     # implementation plan
        tasks/
          01-<task-name>.md         # NN-prefix matches run order
          02-<task-name>.md
  complete/
    YYYYMMDD-<project-slug>/        # archived by /sdlc-complete (date appended on archive)
```

Project-level ADRs live in `adr.md`; decisions strong enough to outlive the project promote to the host repo under `docs/adrs/<YYYYMMDD>-<slug>.md` and load at the start of every future design session. `prd.md` is optional, but when present every epic's `spec.md` MUST cite it under `## Dependencies` and trace each FR to a PRD section — unreferenced PRDs drop at signoff. Each task drives one branch and one PR, stacked on the previous task's branch.

## Agents

| Agent | Model | Effort | Description |
|---|---|---|---|
| `sdlc-architect` | opus | xhigh | Design-phase architecture, intake, research, and document authoring for the SDLC flow; owns specs, plans, tasks, MANIFEST and enforces stack-linearity and NN-ordering. SDLC-only |
| `sdlc-tester` | sonnet | high | TDD discipline — red-first batches and full-suite reruns — for the SDLC flow; reworks drift reported by the coordinator's third-party validator. SDLC-only |
| `sdlc-coder` | sonnet | high | Smallest-diff implementation specialist for the SDLC flow. SDLC-only |

`sdlc-architect` is spawned by `/sdlc-design` once per design session; `sdlc-tester` and `sdlc-coder` by `/sdlc-implement` once per task. Each is launched via the `Agent` tool (`subagent_type` set to the agent's name) and resumed thereafter with `SendMessage` addressed to that same name, which restores its full transcript — that persistence is what lets the tester write batch 2 knowing what batch 1 revealed. The architect owns research and document authoring inline. Each SDLC agent carries a one-line signature phrase that restates its hardest rule.

Unlike skills, agents pin `model` and `effort`: they spawn as fresh processes with no session to inherit from, so the tier is part of the role definition. Tester and coder run on `sonnet` — writing table-driven tests against a written spec and greening them with the smallest diff is routine coding, and the batched TDD loop is the flow's dominant token cost. Judgment-heavy roles stay on `opus`: the architect, and the one-shot spec-vs-code validator `/sdlc-implement` spawns.

## File Layout

```
skills/                             # shared by Claude Code and Gemini CLI
  <name>/SKILL.md
agents/                             # Claude Code agents
  sdlc-architect/AGENT.md
  sdlc-tester/AGENT.md
  sdlc-coder/AGENT.md
claude/                             # Claude Code project settings
  settings.json
  statusline.sh                     # symlinked to ~/.claude/statusline.sh
```

## License

MIT -- see [LICENSE](LICENSE).
