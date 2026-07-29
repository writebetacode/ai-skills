# AI Instructions

## Documentation

Documentation must be kept in sync with every change. Any addition, removal, or modification to skills, commands, agents, settings keys, or the `plans/` file layout requires a corresponding documentation update before the task is considered complete.

There are four documents. Update the one that owns the subject:

| Document | Owns |
| --- | --- |
| `README.md` | The command tables, the file layout, and quick-start install |
| `docs/installation.md` | Install and `config.yml`, Taskfile targets, git safety rules, settings keys, the status line |
| `docs/skills.md` | Skill behaviour that spans more than one skill, or that a `SKILL.md` cannot state on its own |
| `docs/sdlc.md` | The three SDLC phases, the `plans/` layout, and the three agents |

Adding or removing a skill or agent touches both `README.md` (its table row) and the doc that covers its behaviour.

Keep `docs/installation.md` about installing. How a skill behaves once installed belongs in `docs/skills.md` or the `SKILL.md` itself, even when the install machinery has a check for it.

Resist adding new documents. Detail belongs in the document that already owns its subject; a new file needs a reason beyond the section growing long.
