---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating both Claude command and Gemini skill files. Use when the user wants to codify a repetitive task into a skill or command.
model: sonnet
---

# Skill Write: Scaffold a New Skill

Use any provided name or description as a starting point, otherwise begin by asking the user what the skill should accomplish.

## Workflow

Begin the discovery phase by asking scoping questions one at a time to determine the skill's name, description, workflow steps, critical rules, and the appropriate model tier. Once the details are gathered, present a full draft of the content for both the Claude command and the Gemini skill files. Ask the user for confirmation and incorporate any requested edits before proceeding to the execution phase. Finally, create the necessary directories and files, ensuring that the Gemini skill is placed in its own subdirectory, and confirm the final file paths to the user.

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

Always ask scoping questions one at a time to avoid overwhelming the user and never write any files without explicit confirmation. Ensure that both Claude and Gemini versions are generated and that the Gemini skill is correctly placed in its own directory. Keep all skills under 100 lines and use only ASCII characters, excluding any AI attribution.

## User Input

$ARGUMENTS
