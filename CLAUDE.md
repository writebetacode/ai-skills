# AI Instructions

## Documentation

Documentation must be kept in sync with every change. Any addition, removal, or modification to skills, commands, agents, settings keys, or the `plans/` file layout requires a corresponding docs update before the task is considered complete.

Reference documentation lives in `docs/`; README.md is an entry point that orients and links out. Update the doc that owns the subject:

| Change | Update |
| --- | --- |
| Skill added, removed, or renamed | `docs/skills.md`, plus the README command table |
| Agent added, removed, or retiered | `docs/agents.md`, plus the README command table |
| SDLC behaviour or `plans/` layout | `docs/sdlc.md` |
| `claude/settings.json` key | `docs/settings.md` |
| `claude/statusline.sh` behaviour | `docs/statusline.md` |
| Install, `config.yml`, or Taskfile targets | `docs/installation.md` |
| Shared PR/MR body template or its markers | `docs/pr-mr-template.md` |

Touch README.md itself only when the change alters the command tables, the doc index, or the top-level file layout — not for detail that belongs in a `docs/` page.
