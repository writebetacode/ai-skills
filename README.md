# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

This symlinks all skills and agents into `~/.claude` and `~/.gemini` so updates pulled from the repo apply immediately without reinstalling. Stale symlinks pointing back to this repo are cleaned up automatically before each install. Agents that require a specific CLI (e.g. `gemini-operative` requires `gemini`, `claude-operative` requires `claude`) are skipped silently if that CLI is not found.

You can also install per platform or verify the current state:

```bash
task install:claude   # Claude only
task install:gemini   # Gemini only
task verify           # check all symlinks are in place
```

## What's included

Skills are available for both Claude Code (`.claude/skills/`) and Gemini CLI (`.gemini/skills/`).

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
| `/skill-write` | Scaffold a new skill by asking scoping questions and writing both Claude and Gemini files |
| `/agent-write` | Scaffold a new Claude Code subagent by asking scoping questions and generating an AGENT.md file |

### Software Development Workflow

A six-phase process to take a feature idea all the way through to merged code. The research phase is optional. Use `/sdlc-kickoff` to run the research, decomposition, and brainstorm phases automatically via an agent team.

| Command | Phase | Description |
|---|---|---|
| `/sdlc-kickoff` | 0 — Kickoff (optional) | Spin up an agent team to research a topic, decompose findings into independent epics, and brainstorm each epic in parallel |
| `/research` | 0 — Research (optional) | Deep-dive research with sourced findings before brainstorming |
| `/sdlc-brainstorm` | 1 — Brainstorm | Turn an idea into a detailed spec through guided questioning |
| `/sdlc-plan` | 2 — Plan | Break a spec into stacked, reviewable PR-sized tasks |
| `/sdlc-validate` | 3 — Validate | Verify the plan has full requirement coverage and no drift |
| `/sdlc-implement` | 4 — Implement | Execute tasks one acceptance criterion at a time with TDD |
| `/sdlc-complete` | 5 — Complete | Archive the finished plan and spec once all tasks are Done |

The commands share a common file layout under `plans/` (add it to `.gitignore`):

```
plans/
  research/
    YYYY-MM-DD-<slug>/            # output of /research
      index.md                    # topic summary, TOC, out-of-scope branches
      questions.md                # Q&A log linking to findings
      findings/
        <slug>.md                 # one file per research area, inline sources
      ai-summary.md               # synthesized digest for AI consumption
  YYYY-MM-DD-<slug>/
    spec.md                       # output of /sdlc-brainstorm
    index.md                      # output of /sdlc-plan
    01-<task-name>.md
    02-<task-name>.md
    ...
  complete/
    YYYY-MM-DD-<slug>/            # archived by /sdlc-complete
```

Each task drives one branch and one PR, stacked on the previous task's branch. Implementation follows a strict RED → GREEN → REFACTOR loop, committing after each passing criterion.

## Agents

| Agent | Platform | Model | Description |
|---|---|---|---|
| `gemini-operative` | Claude | inherited | On-demand Gemini-powered research, audits, and execution via the `gemini` CLI |
| `claude-operative` | Gemini | opus/sonnet | On-demand Claude-powered research, audits, and execution via the `claude` CLI |

## License

MIT — see [LICENSE](LICENSE).
