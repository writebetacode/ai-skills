# ai-skills

A collection of skills and agents for AI coding assistants that bring structured, opinionated workflows to everyday software development tasks.

## Quick start

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Everything installs by default. To opt out of specific skills or agents, or to skip a platform, see [Installation and configuration](docs/installation.md).

## Skills

Every git-facing skill resolves the repo's default branch from `origin/HEAD` rather than assuming `main`, so they behave correctly on repos that default to `develop`, `master`, or `trunk`. None pin a model — each runs on whatever model your session is already using, so invoking a skill never silently changes tiers or costs.

| Command | Description |
|---|---|
| `/commit` | Stage-aware conventional commits — commits exactly what is staged, immediately |
| `/pr` | Create or update GitHub pull requests with structured descriptions |
| `/mr` | Create or update GitLab merge requests with the same structured description, via `glab` |
| `/mr-review` | Review a GitLab MR into a numbered `docs/mr-reviews/<mr#>.md` report, then post selected findings back as inline discussions |
| `/restack` | Rebase open branches onto the latest default branch, whether their base was squash-merged or the default branch simply moved ahead |
| `/prune-branches` | Delete local branches whose changes already landed in the default branch, including squash-merged branches `git branch -d` refuses as unmerged |
| `/gh-issue` | Create consistently-formatted GitHub issues with type, priority, and optional context sections |
| `/gh-release` | Tag the default branch and publish a GitHub release, inferring the version from commit history and drafting notes in the repo's established voice |

`/pr` and `/mr` share a body template with rules of its own, and `/mr-review` splits reviewing from posting — see [Skill behaviour](docs/skills.md).

## SDLC workflow

A manifest-driven process from feature idea to merged code, run by three persistent agents. Full mechanics in [SDLC workflow](docs/sdlc.md).

| Command | Phase | Description |
|---|---|---|
| `/sdlc-design` | 1 — Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent |
| `/sdlc-implement` | 2 — Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, and third-party spec-vs-code validation |
| `/sdlc-complete` | 3 — Complete | Archive a finished project and clean up its local branches |

## Documentation

- [Installation and configuration](docs/installation.md) — install, opt-outs, settings keys, status line, verification
- [Skill behaviour](docs/skills.md) — the shared PR/MR body template and how `/mr-review` splits reviewing from posting
- [SDLC workflow](docs/sdlc.md) — the three phases, the `plans/` layout, and the agents

## File layout

```
skills/                             # one SKILL.md per skill
  <name>/SKILL.md
agents/                             # one AGENT.md per agent
  <name>/AGENT.md
claude/                             # global claude code specific settings
docs/                               # documentation
```

## License

MIT -- see [LICENSE](LICENSE).
