# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

This symlinks all skills and agents into `~/.claude` and `~/.gemini` so updates pulled from the repo apply immediately without reinstalling. Stale symlinks pointing back to this repo are cleaned up automatically before each install.

You can also install per platform or verify the current state:

```bash
task install:claude   # Claude only
task install:gemini   # Gemini only
task verify           # check all symlinks are in place
```

## What's included

Skills are available for both Claude Code (`.claude/`) and Gemini CLI (`.gemini/`).

### Git & GitHub

| Command | Description |
|---|---|
| `/commit` | Stage-aware conventional commits with user confirmation |
| `/pr` | Create or update pull requests with structured descriptions |
| `/restack` | Rebase stacked branches after upstream squash merges |

### Meta

| Command | Description |
|---|---|
| `/skill-write` | Scaffold a new skill by asking scoping questions and writing both Claude and Gemini files |

### Software Development Workflow

A four-phase process to take a feature idea all the way through to merged code.

| Command | Phase | Description |
|---|---|---|
| `/sdlc-brainstorm` | 1 — Brainstorm | Turn an idea into a detailed spec through guided questioning |
| `/sdlc-plan` | 2 — Plan | Break a spec into stacked, reviewable PR-sized tasks |
| `/sdlc-validate` | 3 — Validate | Verify the plan has full requirement coverage and no drift |
| `/sdlc-implement` | 4 — Implement | Execute tasks one acceptance criterion at a time with TDD |

The four commands share a common file layout under `plans/` (add it to `.gitignore`):

```
plans/
  specs/
    YYYY-MM-DD-<slug>.md          # output of /sdlc-brainstorm
  implementations/
    <slug>/
      index.md                    # output of /sdlc-plan
      01-<task-name>.md
      02-<task-name>.md
      ...
  complete/
    YYYY-MM-DD-<slug>/            # archived after /sdlc-implement finishes
```

Each task drives one branch and one PR, stacked on the previous task's branch. Implementation follows a strict RED → GREEN → REFACTOR loop, committing after each passing criterion.

## Agents

| Agent | Platform | Model | Description |
|---|---|---|---|
| `gemini-operative` | Claude | sonnet | On-demand Gemini-powered research, audits, and execution via the `gemini` CLI |
| `operative` | Gemini | opus/sonnet | On-demand Claude-powered research, audits, and execution via the `claude` CLI |

## License

MIT — see [LICENSE](LICENSE).
