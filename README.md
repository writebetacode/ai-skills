# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

This symlinks all skills and agents into `~/.claude` and `~/.gemini` so updates pulled from the repo apply immediately without reinstalling. A single set of skill files serves both platforms. Stale symlinks pointing back to this repo are cleaned up automatically before each install. Agents that require a specific CLI (e.g. `gemini-operative` requires `gemini`, `claude-operative` requires `claude`) are skipped silently if that CLI is not found.

You can also install per platform or verify the current state:

```bash
task install:claude   # Claude only
task install:gemini   # Gemini only
task verify           # check all symlinks are in place
```

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

A manifest-driven process to take a feature idea all the way through to merged code. `/sdlc-design` is the single entry point -- it handles research, strict one-question-at-a-time clarification, spec creation, and implementation planning through a persistent architect-led agent team that also handles mid-flight architectural revisions. The architect enforces stack-linearity (every task has exactly one parent branch) and NN-prefix ordering (task 01 runs first, 02 second, no gaps). The architect may also mark individual tasks `Depth: ultrathink` so `/sdlc-implement` boosts the tester and coder to maximum reasoning depth on genuinely gnarly work; routine tasks omit the field. When scope grows beyond a single epic, design creates a `MANIFEST.md` that every downstream skill reads and updates.

| Command | Phase | Model | Description |
|---|---|---|---|
| `/sdlc-design` | 1 -- Design | opus | Turn an idea into specs, plans, and ADRs through strict one-at-a-time questioning and an architect-led team; also handles mid-flight revisions via per-task keep/revise/void triage |
| `/sdlc-implement` | 2 -- Implement | opus | Execute tasks with a tester-coder team, TDD loop, and third-party spec-vs-code validation; auto-picks the next task from the manifest when called without arguments |
| `/sdlc-complete` | 3 -- Complete | sonnet | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |

The commands share a common file layout under `plans/` (keep this directory out of version control in your global gitignore):

```
plans/
  <project-slug>/                   # project folder (from /sdlc-design, no date prefix)
    MANIFEST.md                     # central control document (always present)
    prd.md                          # optional -- WHAT users need (product requirements)
    adr.md                          # running log of project-level architecture decisions
    epics.md                        # epic list, dependency graph, and build order (multi-epic)
    research/<topic>.md             # researcher citations
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

Project-level ADRs live in `adr.md`; decisions strong enough to outlive the project are promoted to the host repo under `docs/adrs/<YYYYMMDD>-<slug>.md` and read at the start of every future design session. Each task drives one branch and one PR, stacked on the previous task's branch. Implementation follows a strict RED -> GREEN -> REFACTOR loop with third-party validation before commit.

## Agents

| Agent | Voice | Model | Effort | Description |
|---|---|---|---|---|
| `sdlc-architect` | Vaughn (he/him) | opus | xhigh | Design-phase architecture, intake questioning, and coherence gatekeeper for the SDLC flow; enforces stack-linearity and NN-ordering. SDLC-only |
| `researcher` | Maren (she/her) | sonnet | high | Fact-gathering and citations; uses context7 for all package/library/SDK lookups. Reusable outside SDLC |
| `document-writer` | Sable (she/her) | sonnet | medium | Generalist structured-prose writer for specs, plans, tasks, PRDs, ADRs, READMEs. Reusable outside SDLC |
| `sdlc-tester` | Rhea (she/her) | opus | high | TDD discipline and independent third-party spec-vs-code validation for the SDLC flow. SDLC-only |
| `sdlc-coder` | Cormac (he/him) | opus | high | Smallest-diff implementation specialist for the SDLC flow. SDLC-only |
| `gemini-operative` | -- | -- | -- | On-demand Gemini-powered research, audits, and execution via the `gemini` CLI (Claude Code only) |
| `claude-operative` | -- | -- | -- | On-demand Claude-powered research, audits, and execution via the `claude` CLI (Gemini CLI only) |

The five SDLC agents (`sdlc-architect`, `researcher`, `document-writer`, `sdlc-tester`, `sdlc-coder`) each carry a self-authored identity with a signature phrase that steers behavior. All five are spawned via TeamCreate by `/sdlc-design` and `/sdlc-implement`. The `sdlc-*` trio is scoped exclusively to those skills; `researcher` and `document-writer` are generalist utilities and remain reusable outside the SDLC flow.

## File Layout

```
skills/                             # shared by Claude Code and Gemini CLI
  <name>/SKILL.md
agents/                             # Claude Code agents (cross-platform where noted)
  sdlc-architect/AGENT.md
  researcher/AGENT.md
  document-writer/AGENT.md
  sdlc-tester/AGENT.md
  sdlc-coder/AGENT.md
  gemini-operative/AGENT.md
  claude-operative/AGENT.md
claude/                             # Claude Code project settings
  settings.json
```

## License

MIT -- see [LICENSE](LICENSE).
