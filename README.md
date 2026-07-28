# ai-skills

A collection of skills and agents for [Claude Code](https://claude.ai/code) and [Gemini CLI](https://github.com/google-gemini/gemini-cli) that bring structured, opinionated workflows to everyday software development tasks.

## Quick start

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Everything installs by default, symlinked into `~/.claude` and `~/.gemini` so repo updates apply immediately. To opt out of specific skills or agents, or to skip a platform, see [Installation](docs/installation.md).

## What's included

Skills are shared by Claude Code and Gemini CLI; agents are Claude Code only.

| | |
|---|---|
| **Git & forges** | `/commit` `/pr` `/mr` `/restack` `/prune-branches` `/gh-issue` `/gh-release` |
| **SDLC workflow** | `/sdlc-design` `/sdlc-implement` `/sdlc-complete` |
| **Agents** | `sdlc-architect` `sdlc-tester` `sdlc-coder` |

Full descriptions: [Skills](docs/skills.md) · [SDLC workflow](docs/sdlc.md) · [Agents](docs/agents.md)

## Documentation

| Document | Covers |
|---|---|
| [Installation](docs/installation.md) | Install, `config.yml` opt-outs, git safety rules, verification and teardown |
| [Settings keys](docs/settings.md) | Every key `claude/settings.json` defines, and why |
| [Status line](docs/statusline.md) | What `claude/statusline.sh` renders and how it degrades |
| [Skills](docs/skills.md) | The git and forge commands, in detail |
| [SDLC workflow](docs/sdlc.md) | Design, implement, complete — and the `plans/` layout |
| [Agents](docs/agents.md) | The three SDLC agents, their lifecycle, and why they pin models |
| [PR/MR body template](docs/pr-mr-template.md) | The shared template, its fence markers, and migration behaviour |

## File layout

```
skills/                             # shared by Claude Code and Gemini CLI
  <name>/SKILL.md
agents/                             # Claude Code agents
  sdlc-architect/AGENT.md
  sdlc-tester/AGENT.md
  sdlc-coder/AGENT.md
claude/                             # Claude Code project settings
  settings.json
  statusline.sh                     # symlinked to ~/.claude/statusline.sh
docs/                               # documentation
```

## License

MIT -- see [LICENSE](LICENSE).
