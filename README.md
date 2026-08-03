# ai-skills

Opinionated skills for Claude Code and Gemini CLI, covering the parts of everyday development that go better with a fixed procedure: commits, pull requests, code review, issues, releases, and a spec-driven SDLC flow.

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

The four forge skills each drive every backend they support from a single file, reading the chosen CLI's command reference on demand and running it in your own session. [Skill behaviour](docs/skills.md) covers what that means in practice, and the handful of behaviours that surprise people.

## SDLC workflow

Three commands that take a feature idea to merged code through written specs and a test-first loop. Full detail in [SDLC workflow](docs/sdlc.md).

| Command | Phase | What it does |
| --- | --- | --- |
| `/sdlc-design` | Design | One-question-at-a-time intake into specs, plans, tasks, and ADRs |
| `/sdlc-implement` | Implement | Branch setup, batched red-green TDD, spec-and-coverage validation, staged diff |
| `/sdlc-complete` | Complete | Archive the plan folder and delete the branches it left behind |

## Agents

No agents ship today. Every skill runs in your own session and reads what it needs on demand, which keeps your permission rules, your tool grants, and your context in one place rather than re-derived behind a handoff. A skill still spawns a subagent where a fresh one earns its keep: a one-shot `Explore` for a wide codebase survey, and the cold-context validator that gates every `/sdlc-implement` task.

Skills pin no model and run on whatever tier your session is already using, so invoking one never silently changes cost. The `agents/` directory and its install path are still wired up, so a project-specific agent can be added without rebuilding anything.

## Layout

```text
skills/<name>/SKILL.md      one per skill, plus optional reference files read on demand
skills/<name>/scripts/      optional executables, reached via ${CLAUDE_SKILL_DIR}
agents/<name>/AGENT.md      one per agent -- none ship today
claude/                     settings.json and statusline.sh, merged on install
docs/                       installation, skill behaviour, SDLC
config.example.yml          copy to config.yml to choose what installs
```

## License

MIT -- see [LICENSE](LICENSE).
