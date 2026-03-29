---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating a skill file. Use when the user wants to codify a repetitive task into a skill.
---

# Skill Write: Scaffold a New Skill

Use any provided name or description as a starting point, otherwise begin by asking the user what the skill should accomplish.

## Workflow

Begin the discovery phase by asking scoping questions one at a time to determine the skill's name, description, workflow steps, critical rules, and the appropriate model tier. Once the details are gathered, present a full draft of the skill content. Ask the user for confirmation and incorporate any requested edits before proceeding to the execution phase. Finally, create the directory and file, and confirm the final path to the user.

## File Format

```yaml
---
name: <name>
description: <description>
---
```

Place the skill at `skills/<name>/SKILL.md` relative to the repo root. Each skill ends with a `## User Input\n\n$ARGUMENTS` section. A single file serves both Claude Code and Gemini CLI -- `task install` symlinks it into `~/.claude/skills/` and `~/.gemini/skills/`.

## Writing Style

Write all skill content — workflow steps, rules, and explanations — as flowing prose paragraphs, not numbered lists or bullet points. Prose keeps intent and reasoning connected across the full workflow, producing better model execution. Numbered steps cause mechanical step-checking without judgment; bullets fragment context and strip the causal connectives ("then", "after", "once") that tell the model why to do something. The only exception is structured reference formats like templates or examples that are genuinely tabular or code-like.

## Updating Existing Skills

When the task is to update an existing skill rather than create a new one, read the current file first and diff the proposed changes against it. Explicitly list any existing functionality that would be removed and ask the user to confirm each removal before writing. Never drop behavioral details silently — if a step, rule, or constraint is present in the current skill, it must either be preserved in the updated version or explicitly approved for removal by the user.

## Rules

Always ask scoping questions one at a time to avoid overwhelming the user and never write any files without explicit confirmation. Ensure the skill is correctly placed in its own subdirectory under `skills/` at the repo root. After writing the skill file, update README.md to include the new skill in the appropriate table. Keep all skills under 100 lines and use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
