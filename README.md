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

| Command | Description |
|---|---|
| `/commit` | Stage-aware conventional commits with user confirmation |
| `/pr` | Create or update pull requests with structured descriptions |
| `/restack` | Rebase stacked branches after upstream squash merges |
| `/prune-branches` | Delete local branches whose commits are fully merged into main |
| `/gh-issue` | Create consistently-formatted GitHub issues with type, priority, and optional context sections |

### Meta

| Command | Description |
|---|---|
| `/skill-write` | Scaffold a new skill by asking scoping questions and writing the skill file |
| `/agent-write` | Scaffold a new Claude Code subagent by asking scoping questions and generating an AGENT.md file |

### Software Development Workflow

A manifest-driven process to take a feature idea all the way through to merged code. `/sdlc-design` is the single entry point -- it handles research, questioning, spec creation, and implementation planning with a persistent architect-led agent team. Each phase self-validates via built-in agent teams, so there is no separate validation step. When scope grows beyond a single epic, design creates a `MANIFEST.md` that every downstream skill reads and updates.

| Command | Phase | Description |
|---|---|---|
| `/sdlc-design` | 1 -- Design | Turn an idea into specs and implementation plans through guided questioning, research, and architect-led agent teams with built-in validation |
| `/sdlc-implement` | 2 -- Implement | Execute tasks with a tester-coder agent team, user review per AC, and built-in revision handling |
| `/sdlc-status` | -- Status | Project dashboard showing what is done, what is actionable, and what to do next |
| `/sdlc-complete` | 3 -- Complete | Archive a finished epic or entire project to plans/complete/ |

The commands share a common file layout under `plans/` (add it to `.gitignore`):

```
plans/
  YYYY-MM-DD-<slug>/                # project folder (from /sdlc-design)
    MANIFEST.md                     # central control document (always present)
    epics.md                        # epic list, dependency graph, and build order (multi-epic)
    research/                       # research output (if conducted)
      index.md, questions.md, findings/, ai-summary.md
    epics/
      YYYY-MM-DD-<epic-slug>/
        spec.md                     # specification (includes edge cases)
        plan.md                     # implementation plan (from /sdlc-design)
        01-<task-name>.md
        02-<task-name>.md
  complete/
    YYYY-MM-DD-<slug>/              # archived by /sdlc-complete
```

Each task drives one branch and one PR, stacked on the previous task's branch. Implementation follows a strict RED -> GREEN -> REFACTOR loop, committing after each passing criterion.

## Agents

| Agent | Platform | Description |
|---|---|---|
| `gemini-operative` | Claude | On-demand Gemini-powered research, audits, and execution via the `gemini` CLI |
| `claude-operative` | Gemini | On-demand Claude-powered research, audits, and execution via the `claude` CLI |

## File Layout

```
skills/                             # shared by Claude Code and Gemini CLI
  <name>/SKILL.md
agents/                             # cross-platform operative agents
  gemini-operative/AGENT.md
  claude-operative/AGENT.md
claude/                             # Claude Code project settings
  settings.json
```

## License

MIT -- see [LICENSE](LICENSE).
