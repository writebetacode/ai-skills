---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating both Claude command and Gemini skill files. Use when the user wants to codify a repetitive task into a skill or command.
model: sonnet
---

# Skill Write: Scaffold a New Skill

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask what the skill should do first.

## Workflow

1.  **Discovery**: Ask scoping questions one at a time:
    - **Name**: kebab-case (e.g., `deploy-service`).
    - **Description**: High-signal, single-line "when to use" statement.
    - **Workflow**: 3-5 clear, numbered steps.
    - **Rules**: Critical guardrails (max 5).
    - **Model Tier**: `opus`/`sonnet` (complex logic) or `flash` (speed/simple tasks).
2.  **Draft**: Present the full content for both `.claude/commands/<name>.md` and `.gemini/skills/<name>/SKILL.md`.
3.  **Confirm**: Ask `Write files? (yes/no/edit)`. If the user provides edits, update the drafts and re-confirm.
4.  **Execute**: 
    - Create the `.claude/commands/` file.
    - Create the `.gemini/skills/<name>/` directory (mandatory) and write the `SKILL.md` inside it.
    - Confirm the final paths to the user.

## File Format

Claude command frontmatter:

```yaml
---
name: <name>
description: <description>
model: <opus|sonnet|flash>
---
```

Gemini skill frontmatter omits `model` (unsupported). Both files end with the same workflow and rules body. Claude command appends `## User Input\n\n$ARGUMENTS`.

## Rules

- One question at a time
- Never write without confirmation
- Always write both files
- Ensure the Gemini skill is in its own directory
- Skills must be under 100 lines
- No AI attribution, ASCII only

## User Input

$ARGUMENTS
