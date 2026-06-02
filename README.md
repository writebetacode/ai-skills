# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Symlinks all skills and agents into `~/.claude` and `~/.gemini` so repo updates apply immediately without reinstalling. A single set of skill files serves both platforms. Stale symlinks pointing back to this repo are cleaned up before each install. CLI-specific agents (`gemini-operative` needs `gemini`, `claude-operative` needs `claude`) are skipped silently if the CLI is missing.

Per-platform install and verification:

```bash
task install:claude            # Claude only
task install:gemini            # Gemini only
task verify                    # check all symlinks
task verify:response-style     # check the shared Response Style block has not drifted
```

The `## Response Style` block is duplicated verbatim across skills that use it (skills load standalone — no include mechanism). Each duplicate is preceded by a `<!-- response-style:v1 -->` marker; `task verify:response-style` reads every tagged block and fails on drift from the canonical first one. When updating the rule, edit every tagged file and bump the marker version.

## What's included

Skills live in `skills/` and are shared by both Claude Code and Gemini CLI.

### Git & GitHub

| Command | Model | Description |
|---|---|---|
| `/commit` | sonnet | Stage-aware conventional commits with user confirmation |
| `/pr` | sonnet | Create or update pull requests with structured descriptions |
| `/restack` | sonnet | Rebase stacked branches after upstream squash merges |
| `/prune-branches` | sonnet | Delete local branches whose commits are fully merged into main |
| `/gh-issue` | sonnet | Create consistently-formatted GitHub issues with type, priority, and optional context sections |

### Meta

| Command | Model | Description |
|---|---|---|
| `/skill-write` | opus | Scaffold a new skill by asking scoping questions and writing the skill file |
| `/agent-write` | opus | Scaffold a new Claude Code subagent by asking scoping questions and generating an AGENT.md file |

### Software Development Workflow

A manifest-driven process from feature idea to merged code. `/sdlc-design` is the single entry point — research, strict one-question-at-a-time clarification, spec creation, implementation planning through a persistent architect agent that also handles mid-flight architectural revisions. The architect runs intake, does its own context7-backed research and codebase reads, authors all artifacts (spec, plan, tasks, MANIFEST), and enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering (01 runs first, 02 second, no gaps). Within an epic, tasks run linearly; across epics, disjoint dependency sets may run in parallel via two `/sdlc-implement` sessions in two checkouts. The tester and coder run at fixed `high` effort and rely on Opus 4.8's adaptive reasoning to self-allocate depth on gnarly steps, so there is no per-task depth flag. When scope exceeds a single epic, design creates a `MANIFEST.md` that every downstream skill reads and updates.

`/sdlc-implement` checkpoints between AC-group test batches instead of handing the coder one monolithic red batch — tester writes batch 1's red tests, coder greens them, then tester writes batch 2 informed by what batch 1 revealed. Before resolving any task in a dependent epic, the skill validates that every epic listed under `## Dependencies` is `Complete` in the manifest. The coder routes blockers: scope drift to the tester, factual/structural ambiguity to the architect, `unbuildable: <reason>` back to the tester for void-or-revise via mid-flight revision. After all batches are green, the tester runs lint and the full suite, updates the task file's `Key Files` to actual files changed, and hands a clean report to the coordinator. The coordinator — not the tester — then spawns a fresh sub-agent (general-purpose) as third-party spec-vs-code validator, handing it only the spec path, task path, and diff range. Coordinator-level spawn keeps the validator unbiased by the tester's "I think this is done" framing and outside the team's lifecycle. The validator returns JSON satisfied/drift; the task approves only on empty drift, otherwise the coordinator routes the drift list back to the tester for another loop.

| Command | Phase | Model | Description |
|---|---|---|---|
| `/sdlc-design` | 1 -- Design | opus | Turn an idea into specs, plans, and ADRs through strict one-at-a-time questioning and an architect-led team; also handles mid-flight revisions via per-task keep/revise/void triage |
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

Project-level ADRs live in `adr.md`; decisions strong enough to outlive the project promote to the host repo under `docs/adrs/<YYYYMMDD>-<slug>.md` and load at the start of every future design session. `prd.md` is optional, but when present every epic's `spec.md` MUST cite it under `## Dependencies` and trace each FR to a PRD section — unreferenced PRDs drop at signoff. Each task drives one branch and one PR, stacked on the previous task's branch. Implementation follows strict RED -> GREEN -> REFACTOR, batched per AC group, with fresh sub-agent third-party spec-vs-code validation before commit.

## Agents

| Agent | Model | Effort | Description |
|---|---|---|---|
| `sdlc-architect` | opus | xhigh | Design-phase architecture, intake, research, and document authoring for the SDLC flow; owns specs, plans, tasks, MANIFEST and enforces stack-linearity and NN-ordering. SDLC-only |
| `sdlc-tester` | opus | high | TDD discipline and independent third-party spec-vs-code validation for the SDLC flow. SDLC-only |
| `sdlc-coder` | opus | high | Smallest-diff implementation specialist for the SDLC flow. SDLC-only |
| `gemini-operative` | -- | -- | On-demand Gemini-powered research, audits, and execution via the `gemini` CLI (Claude Code only) |
| `claude-operative` | -- | -- | On-demand Claude-powered research, audits, and execution via the `claude` CLI (Gemini CLI only) |

`sdlc-architect` is spawned via TeamCreate by `/sdlc-design`; `sdlc-tester` and `sdlc-coder` by `/sdlc-implement`. The architect owns research and document authoring inline. Each SDLC agent carries a one-line signature phrase that restates its hardest rule.

## File Layout

```
skills/                             # shared by Claude Code and Gemini CLI
  <name>/SKILL.md
agents/                             # Claude Code agents (cross-platform where noted)
  sdlc-architect/AGENT.md
  sdlc-tester/AGENT.md
  sdlc-coder/AGENT.md
  gemini-operative/AGENT.md
  claude-operative/AGENT.md
claude/                             # Claude Code project settings
  settings.json
```

## License

MIT -- see [LICENSE](LICENSE).
