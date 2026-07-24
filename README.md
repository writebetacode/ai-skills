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

`task verify` follows the same config: excluded items are checked to be *absent*, so a stale symlink from a previous install is reported as an error.

`task install` also merges `claude/settings.json` into `~/.claude/settings.json`: the permission `allow`/`ask`/`deny` lists are unioned, and every other key takes the repo's value — the repo is the source of truth for the settings it defines, so local edits to those keys are overwritten on each install. `task uninstall` removes every symlink pointing into this repo and subtracts the repo-defined settings back out of `~/.claude/settings.json`: permission entries listed in the repo are removed (including any you happened to add independently — re-add those if needed), repo-defined keys are deleted, and everything the repo never defined survives untouched.

Verification and teardown:

```bash
task uninstall                 # remove symlinks and subtract repo-defined settings
task verify                    # run every check below, in order
task verify:skills-installed   # check all symlinks
task verify:response-style     # check the shared Response Style block has not drifted
task verify:pr-body            # check the shared PR/MR body template has not drifted
```

`task verify` runs the three checks sequentially and stops at the first failure, so fix an early failure to see the later checks run.

The `## Response Style` block is duplicated verbatim across skills that use it (skills load standalone — no include mechanism). Each duplicate is preceded by a `<!-- response-style:v1 -->` marker; `task verify:response-style` reads every tagged block and fails on drift from the canonical first one. When updating the rule, edit every tagged file and bump the marker version.

The PR/MR body template is shared the same way between `/pr` and `/mr`, marked with `<!-- pr-body:v1 -->` and checked by `task verify:pr-body`. The marker sits below the section heading, so `## PR Body Template` and `## MR Body Template` may differ while everything from the intro line through the closing fence stays byte-identical. Review artifacts read the same on both forges; edit both files and bump the marker together.

## What's included

Skills live in `skills/` and are shared by both Claude Code and Gemini CLI.

### Git, GitHub & GitLab

| Command | Model | Description |
|---|---|---|
| `/commit` | sonnet | Stage-aware conventional commits — commits exactly what is staged, immediately |
| `/pr` | sonnet | Create or update GitHub pull requests with structured descriptions |
| `/mr` | sonnet | Create or update GitLab merge requests with the same structured description, via `glab` |
| `/restack` | sonnet | Rebase open branches onto the latest main, whether their base was squash-merged or main simply moved ahead |
| `/prune-branches` | sonnet | Delete local branches whose commits are fully merged into main |
| `/gh-issue` | sonnet | Create consistently-formatted GitHub issues with type, priority, and optional context sections |

### Meta

| Command | Model | Description |
|---|---|---|
| `/skill-write` | opus | Scaffold a new reusable workflow skill by asking scoping questions and writing the skill file |

### Software Development Workflow

A manifest-driven process from feature idea to merged code. `/sdlc-design` is the single entry point: a persistent architect agent runs strict one-question-at-a-time intake and context7-backed research, authors all artifacts (spec, plan, tasks, MANIFEST), enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering, and handles mid-flight revisions via per-task keep/revise/void triage. Within an epic, tasks run linearly; across epics, disjoint dependency sets may run in parallel via two `/sdlc-implement` sessions in two checkouts.

`/sdlc-implement` runs a tester-coder team through a batched TDD loop — tester writes an AC group's red tests, coder greens them, later batches learn from earlier ones — and gates each task on its epic's dependencies being `Complete` in the manifest. After lint and a full-suite pass, the coordinator (not the tester) spawns a fresh sub-agent as an unbiased third-party spec-vs-code validator; the task approves only when the validator reports no drift. Full mechanics live in the two SKILL.md files and the tester/coder AGENT.md files.

| Command | Phase | Model | Description |
|---|---|---|---|
| `/sdlc-design` | 1 -- Design | opus | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning and an architect-led agent team; also handles mid-flight revisions via per-task keep/revise/void triage |
| `/sdlc-implement` | 2 -- Implement | opus | Execute tasks with a tester-coder team, batched TDD loop, epic-precondition gate, and third-party spec-vs-code validation via a fresh sub-agent; auto-picks the next task from the manifest when called without arguments |
| `/sdlc-complete` | 3 -- Complete | sonnet | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |

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
| `sdlc-tester` | opus | high | TDD discipline — red-first batches and full-suite reruns — for the SDLC flow; reworks drift reported by the coordinator's third-party validator. SDLC-only |
| `sdlc-coder` | opus | high | Smallest-diff implementation specialist for the SDLC flow. SDLC-only |

`sdlc-architect` is spawned via TeamCreate by `/sdlc-design`; `sdlc-tester` and `sdlc-coder` by `/sdlc-implement`. The architect owns research and document authoring inline. Each SDLC agent carries a one-line signature phrase that restates its hardest rule.

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
```

## License

MIT -- see [LICENSE](LICENSE).
