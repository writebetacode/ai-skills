---
name: agent-write
description: Scaffold a new Claude Code subagent by asking scoping questions and generating an AGENT.md file. Use when the user wants to codify a specialized workflow into a reusable subagent.
model: opus
---

# Agent Write: Scaffold a New Agent

Use any provided name or description as a starting point; otherwise ask what the agent should accomplish.

## Workflow

Ask scoping questions one at a time to determine name, description, invocation mode (on-demand vs proactive), tools, memory setting, model tier and effort, workflow steps, and rules. The description field determines when Claude invokes the agent — state concrete trigger conditions and any "do not invoke" constraints; include "PROACTIVELY" to opt into proactive invocation, otherwise the agent stays on-demand. Present a full AGENT.md draft, get explicit confirmation, incorporate edits, write to `agents/<name>/AGENT.md`, confirm the path.

## File Format

```yaml
---
name: <name>
description: <description>
tools: [Tool1, Tool2]
memory: none
model: <opus | sonnet | haiku>
effort: <low | medium | high | xhigh | max>
---
```

Omit `model` and `effort` unless a specific tier is required, in which case set both. Pick `model` by task weight — opus for design/architecture/spec authoring, sonnet for routine coding and mechanical edits, haiku for read-only lookups. Pick `effort` by reasoning load: `high` (default) for most work, `xhigh` or `max` for subtle correctness or novel territory, `low`/`medium` for shallow scans. Opus 4.8 reasons adaptively within a tier, so a single fixed effort suffices — there is no per-invocation effort override. Omit `tools` only if inheriting all session tools; otherwise scope narrowly. Set `memory: none` unless persistent state across conversations is needed (omit to enable the default memory directory).

## Writing Style

Write workflow and rules as flowing prose paragraphs, not numbered lists or bullets. Prose keeps intent and reasoning connected; bullets fragment context and strip causal connectives. Structured reference data (mode tables, command examples) is the only exception.

## Updating Existing Agents

Read the current file first and diff proposed changes. Explicitly list any functionality that would be removed; get per-item confirmation before writing. Never drop behavioral details silently.

<!-- response-style:v1 — keep this block byte-identical across all skills; verify with `task verify:response-style`. -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Always ask scoping questions one at a time; never write files without explicit confirmation. After writing, update README.md to include the new agent in the appropriate table. Keep agents under 100 lines. Use only ASCII; never include AI attribution or "Co-Authored-By" lines. Prefer dedicated tools over shell commands in generated workflow text (Read/Edit/Write/Glob/Grep over `cat`/`sed`/`find`/`rg`). No Gemini counterpart — agents are Claude Code-specific.

## User Input

$ARGUMENTS
