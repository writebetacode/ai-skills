# ai-skills

Opinionated skills and agents for Claude Code and Gemini CLI, covering the parts of everyday development that go better with a fixed procedure: commits, pull requests, code review, issues, releases, and a spec-driven SDLC flow.

## Quick start

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Everything is symlinked into `~/.claude` and `~/.gemini`, so edits in the repo take effect without reinstalling. Everything installs by default — see [Installation](docs/installation.md) to opt out of pieces, and to review what the install writes to your Claude Code settings.

## Skills

| Command | What it does |
| --- | --- |
| `/commit` | Conventional commit from exactly what is staged, with no confirmation step |
| `/pr` | Open or update a PR/MR with a structured description; move one between draft and ready |
| `/pr-review` | Review a PR/MR into a numbered local report, then optionally post it as one review |
| `/remote-issue` | File a GitHub or GitLab issue, or a Jira work item |
| `/remote-release` | Tag the default branch and publish a release, with notes drafted from history |
| `/skill-write` | Author or revise any file under `skills/` or `agents/` in this repo, including the reference files and templates beside them |

The four forge skills each drive every backend they support from a single file, dispatching remote commands to a per-CLI agent. [Skill behaviour](docs/skills.md) covers what that means in practice, and the handful of behaviours that surprise people.

## SDLC workflow

Three commands that take a feature idea to merged code through written specs and a test-first loop. Full detail in [SDLC workflow](docs/sdlc.md).

| Command | Phase | What it does |
| --- | --- | --- |
| `/sdlc-design` | Design | One-question-at-a-time intake into specs, plans, tasks, and ADRs |
| `/sdlc-implement` | Implement | Branch setup, batched red-green TDD, spec-vs-code validation, staged diff |
| `/sdlc-complete` | Complete | Archive the plan folder and delete the branches it left behind |

## Agents

Agents run the CLIs that skills never call directly. They install to `~/.claude` only; Gemini CLI gets the skills but has nothing to dispatch to.

| Agent | Model | Invoked by |
| --- | --- | --- |
| `gh` | sonnet | `/pr`, `/pr-review`, `/remote-issue`, `/remote-release` on GitHub |
| `glab` | sonnet | the same four, on GitLab |
| `acli` | sonnet | `/remote-issue`, on Jira |
| `sdlc-architect` | opus | `/sdlc-design` |
| `sdlc-tester` | opus | `/sdlc-implement` |
| `sdlc-coder` | sonnet | `/sdlc-implement` |

Skills pin no model and run on whatever tier your session is already using, so invoking one never silently changes cost. Agents pin a model and effort level because they spawn fresh, with no session to inherit from.

## Layout

```text
skills/<name>/SKILL.md      one per skill, plus optional reference files read on demand
skills/<name>/scripts/      optional executables, reached via ${CLAUDE_SKILL_DIR}
agents/<name>/AGENT.md      one per agent
claude/                     settings.json and statusline.sh, merged on install
docs/                       installation, skill behaviour, SDLC
config.example.yml          copy to config.yml to choose what installs
```

## License

MIT -- see [LICENSE](LICENSE).
