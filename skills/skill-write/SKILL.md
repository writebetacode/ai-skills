---
name: skill-write
description: Scaffold a new reusable workflow skill by asking scoping questions and generating a skill file. Use when the user wants to codify a repetitive task into a skill.
model: opus
---

# Skill Write

Use any provided name or description as a starting point; otherwise ask what the skill should accomplish.

## Workflow

Ask scoping questions one at a time for name, description, model tier, workflow steps, and rules. Pick a tier by task weight — `haiku` for read-only lookups and scans, `sonnet` for routine coding, commits, PRs, and mechanical edits, `opus` for design, architecture, scaffolding, spec authoring, and code review; use the bare aliases, which resolve to the latest in each family. Omit `model` only when inheriting the caller's tier is genuinely appropriate. If the workflow delegates to sub-agents via `Agent` or `TeamCreate`, ask the same tier question per role. Present a full draft, get explicit confirmation, incorporate edits, create the directory and file, confirm the path.

## File Format

```yaml
---
name: <name>
description: <description>
model: <haiku | sonnet | opus>
---
```

Place at `skills/<name>/SKILL.md` relative to repo root. Each skill ends with `## User Input\n\n$ARGUMENTS`. A single file serves both Claude Code and Gemini CLI — `task install` symlinks it into `~/.claude/skills/` and `~/.gemini/skills/`. The `description` is how the model decides when to invoke — state the concrete trigger ("Use when the user wants to …") and, where ambiguity is likely, when to skip.

## Writing Style

Write all skill content — workflow, rules, explanations — as flowing prose paragraphs, not numbered lists or bullets. Prose keeps intent and reasoning connected; numbered steps cause mechanical step-checking without judgment; bullets fragment context and strip causal connectives ("then", "after", "once"). Exception: structured reference formats like templates or tabular/code-like examples.

## Token Efficiency

Skills sit in system context and are paid for on every invocation; redundant words have a recurring cost. Keep prose tight: drop filler openers ("Begin by", "Start by", "Finally"), collapse repetitive connectives, merge sequential sentences sharing a subject, prefer one strong sentence over two weak ones. Fidelity is non-negotiable — every quoted command, flag, template section, and explicit rule preserved verbatim; every behavioral detail (confirmation gates, stop conditions, ordering constraints) intact. Tighten only the connective prose around the functional payload.

## Updating Existing Skills

When updating rather than creating, read the current file first and diff proposed changes. Explicitly list any functionality that would be removed and confirm each removal before writing. Never drop behavioral details silently — every step, rule, and constraint must be preserved or explicitly approved for removal. Pure prose tightening under Token Efficiency is not a removal and does not need per-edit confirmation, as long as every command, template, and rule remains intact.

<!-- response-style:v1 — keep this block byte-identical across all skills; verify with `task verify:response-style`. -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Always ask scoping questions one at a time; never write files without explicit confirmation. Place each skill in its own subdirectory under `skills/` at the repo root. After writing, update README.md to include the new skill in the appropriate table. Keep skills under 100 lines. Use only ASCII; never include AI attribution or "Co-Authored-By" lines. Prefer dedicated tools over shell commands in generated workflow text (Read/Edit/Write/Glob/Grep over `cat`/`sed`/`find`/`rg`) so skills read the same way the host CLIs execute them.

## User Input

$ARGUMENTS
