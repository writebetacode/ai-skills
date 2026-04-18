---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating a skill file. Use when the user wants to codify a repetitive task into a skill.
---

# Skill Write: Scaffold a New Skill

Use any provided name or description as a starting point, otherwise begin by asking the user what the skill should accomplish.

## Workflow

Ask scoping questions one at a time to determine the skill's name, description, workflow steps, and rules. If the workflow will delegate to sub-agents via the `Agent` or `TeamCreate` tools, also ask which model tier fits each delegated role — Haiku for read-only lookups and scans, Sonnet for routine coding and edits, Opus for design, architecture, spec authoring, and code review — defaulting to `inherit` when the caller's tier is appropriate. Skills themselves run inline in the caller's model context and have no model field of their own, so only raise the tier question when the skill actually spawns agents. Once details are gathered, present a full draft, get explicit confirmation, incorporate edits, then create the directory and file and confirm the final path.

## File Format

```yaml
---
name: <name>
description: <description>
---
```

Place the skill at `skills/<name>/SKILL.md` relative to the repo root. Each skill ends with a `## User Input\n\n$ARGUMENTS` section. A single file serves both Claude Code and Gemini CLI -- `task install` symlinks it into `~/.claude/skills/` and `~/.gemini/skills/`. The `description` field is how the model decides when to invoke the skill, so it must state the concrete trigger ("Use when the user wants to …") and, where ambiguity is likely, the conditions under which it should be skipped.

## Writing Style

Write all skill content — workflow steps, rules, and explanations — as flowing prose paragraphs, not numbered lists or bullet points. Prose keeps intent and reasoning connected across the full workflow, producing better model execution. Numbered steps cause mechanical step-checking without judgment; bullets fragment context and strip the causal connectives ("then", "after", "once") that tell the model why to do something. The only exception is structured reference formats like templates or examples that are genuinely tabular or code-like.

## Token Efficiency

Skills sit in system context and are paid for on every invocation, so every redundant word has a recurring cost. Keep prose tight: drop filler openers like "Begin by", "Start by", and "Finally", collapse repetitive connectives, merge sequential sentences that share a subject, and prefer one strong sentence over two weak ones. Fidelity is non-negotiable — every quoted command, flag, template section, and explicit rule must be preserved verbatim, and every behavioral detail (confirmation gates, stop conditions, ordering constraints) must survive intact. Tighten only the connective prose around the functional payload.

## Updating Existing Skills

When the task is to update an existing skill rather than create a new one, read the current file first and diff the proposed changes against it. Explicitly list any existing functionality that would be removed and ask the user to confirm each removal before writing. Never drop behavioral details silently — if a step, rule, or constraint is present in the current skill, it must either be preserved in the updated version or explicitly approved for removal by the user. Pure prose tightening under the Token Efficiency rules above is not a removal and does not require per-edit confirmation, as long as every command, template, and rule remains intact.

## Rules

Always ask scoping questions one at a time to avoid overwhelming the user and never write any files without explicit confirmation. Ensure the skill is correctly placed in its own subdirectory under `skills/` at the repo root. After writing the skill file, update README.md to include the new skill in the appropriate table. Keep all skills under 100 lines and use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines. Prefer dedicated tools over shell commands in generated workflow text (Read/Edit/Write/Glob/Grep over `cat`/`sed`/`find`/`rg`) so the skill reads the same way the host CLIs execute it.

## User Input

$ARGUMENTS
