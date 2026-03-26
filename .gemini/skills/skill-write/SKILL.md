---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating both Claude command and Gemini skill files. Use when the user wants to codify a repetitive task into a skill or command.
---

# Skill Write: Scaffold a New Skill

If the user provides a name or description (via `$ARGUMENTS` or conversational context), use it as the starting point. Otherwise, ask what the skill should accomplish.

## Workflow

1.  **Discovery**: Ask scoping questions one at a time:
    - **Name**: kebab-case (e.g., `deploy-service`).
    - **Description**: High-signal, single-line "when to use" statement.
    - **Workflow**: 3-5 clear, numbered steps.
    - **Rules**: Critical guardrails (max 5).
    - **Model Tier**: `pro` (complex logic) or `flash` (speed/simple tasks).
2.  **Draft**: Present the full content for both `.claude/commands/<name>.md` and `.gemini/skills/<name>/SKILL.md`.
3.  **Confirm**: Ask `Write files? (yes/no/edit)`. If the user provides edits, update the drafts and re-confirm.
4.  **Execute**: 
    - Create the `.claude/commands/` file.
    - Create the `.gemini/skills/<name>/` directory and write the `SKILL.md` inside it.
    - Confirm the final paths to the user.

## File Format

### Claude Command Frontmatter
```yaml
---
name: <name>
description: <description>
model: <opus|sonnet|flash>
---
```

### Gemini Skill Frontmatter
```yaml
---
name: <name>
description: <description>
---
```

**Mapping Logic**:
- **Claude**: Maps `pro` -> `sonnet` (or `opus`) and `flash` -> `sonnet`. Appends `## User Input\n\n$ARGUMENTS`.
- **Gemini**: Omits the `model` field.

## Rules

- One question at a time to avoid overwhelming the user.
- Never write files without explicit confirmation.
- Always generate both the Claude and Gemini versions.
- Ensure the Gemini skill is in its own directory (`.gemini/skills/<name>/SKILL.md`).
- Skills must be under 100 lines.
- No AI attribution, ASCII only.
