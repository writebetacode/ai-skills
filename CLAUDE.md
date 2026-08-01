# AI Instructions

## Authoring skills and agents

Load the `skill-write` skill before creating or editing any file under `skills/` or `agents/`, however small the change looks, and follow it as written -- scoping questions one at a time until the scope is settled, then the write. That covers the reference files and templates beside a `SKILL.md`, not only the `SKILL.md` and `AGENT.md` themselves: a template's section and field names are a contract other files read back, so it is exactly where an edit made from memory does damage without looking like it did. Working from a memory of its rules is not the same as loading it: this instruction exists because that substitution has already happened, and the pass that catches a restatement or a dropped rule-bearing sentence is the pass that gets skipped.

**Authoring violation:** editing any file under `skills/` or `agents/` without loading `skill-write` first, including a file the change only touches in passing and a rule restated from memory of the skill. A one-line fix to a command table, or a renamed heading in a `templates.md`, made directly because the edit looked too small to be worth the load, is a violation; loading the skill and then making that same one-line fix is not.

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
