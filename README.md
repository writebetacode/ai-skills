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

Every git-facing skill resolves the repo's default branch from `origin/HEAD` rather than assuming `main`, so they behave correctly on repos that default to `develop`, `master`, or `trunk`. No skill pins a model — each runs on whatever model your session is already using, so invoking a skill never silently changes tiers or costs. Agents do pin one, since they spawn fresh with no session to inherit from.

| Command | Description |
| --- | --- |
| `/commit` | Stage-aware conventional commits — commits exactly what is staged, immediately |
| `/skill-write` | Author or revise a SKILL.md or AGENT.md — the frontmatter contract, the description rules that decide whether a skill fires, and the token-efficiency and progressive-disclosure rules for what earns a place in the file |
| `/pr` | Create or update pull requests and merge requests with structured descriptions, and move one between draft and ready, on GitHub or GitLab |
| `/pr-review` | Review a PR or MR into a numbered `docs/pr-reviews/<number>.md` report, post selected findings back as inline comments, `--submit` the whole review with a verdict, or `--follow-up` on the threads it started |
| `/remote-issue` | File a consistently-formatted GitHub or GitLab issue, or a Jira work item, prompting for the tracker and the fields it requires |
| `/remote-release` | Tag the default branch and publish a GitHub or GitLab release, inferring the version from commit history and drafting notes in the repo's established voice |

`/pr`, `/pr-review`, `/remote-issue`, and `/remote-release` each serve every backend they support from one file, delegating every remote command to a per-CLI agent:

| Agent | Model | Effort | Description |
| --- | --- | --- | --- |
| `gh` | sonnet | medium | Executes GitHub pull request, issue, and release operations through the `gh` CLI on a caller's work order — view, list, create, edit, review, merge, publish, delete |
| `glab` | sonnet | medium | Executes GitLab merge request, issue, and release operations through the `glab` CLI on a caller's work order — view, list, create, edit, review, merge, publish, delete |
| `acli` | sonnet | medium | Executes Jira work item operations through the Atlassian CLI on a caller's work order — view, search, create, edit, comment, transition, assign, delete |

The body template has rules of its own, and `/pr-review` splits reviewing from posting — see [Skill behaviour](docs/skills.md).

## SDLC workflow

A manifest-driven process from feature idea to merged code, run by three persistent agents. Full mechanics in [SDLC workflow](docs/sdlc.md).

| Command | Phase | Description |
| --- | --- | --- |
| `/sdlc-design` | 1 — Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent |
| `/sdlc-implement` | 2 — Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, and third-party spec-vs-code validation |
| `/sdlc-complete` | 3 — Complete | Archive a finished project and clean up its local branches |

## Documentation

- [Installation and configuration](docs/installation.md) — install, opt-outs, settings keys, status line, verification
- [Skill behaviour](docs/skills.md) — the PR/MR body template, the per-CLI agent boundary, when a template earns its own file, and how `/pr-review` splits reviewing from posting
- [SDLC workflow](docs/sdlc.md) — the three phases, the `plans/` layout, and the agents

## File layout

```text
skills/                             # one SKILL.md per skill
  <name>/SKILL.md
  <name>/<reference>.md             # optional, read on demand (see docs/skills.md)
agents/                             # one AGENT.md per agent
  <name>/AGENT.md
claude/                             # global claude code specific settings
docs/                               # documentation
.markdownlint.jsonc                 # Markdown rules for every file here (task lint:md)
```

## License

MIT -- see [LICENSE](LICENSE).
