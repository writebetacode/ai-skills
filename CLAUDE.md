# AI Instructions

## Documentation

Documentation must be kept in sync with every change. Any addition, removal, or modification to skills, commands, agents, settings keys, or the `plans/` file layout requires a corresponding documentation update before the task is considered complete.

There are three documents. Update the one that owns the subject:

| Document | Owns |
| --- | --- |
| `README.md` | The command tables, the file layout, and quick-start install |
| `docs/installation.md` | Install and `config.yml`, Taskfile targets, git safety rules, settings keys, status line, the shared PR/MR body template |
| `docs/sdlc.md` | The three SDLC phases, the `plans/` layout, and the three agents |

Adding or removing a skill or agent touches both `README.md` (its table row) and the doc that covers its behaviour.

Resist adding new documents. Detail belongs in the document that already owns its subject; a new file needs a reason beyond the section growing long.
