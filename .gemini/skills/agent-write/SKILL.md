---
name: agent-write
description: Scaffold a new Claude Code subagent by asking scoping questions and generating an AGENT.md file. Use when the user wants to codify a specialized workflow into a reusable subagent.
---

# Agent Write: Scaffold a New Agent

Use any provided name or description as a starting point, otherwise begin by asking the user what the agent should accomplish.

## Workflow

Begin the discovery phase by asking scoping questions one at a time to determine the agent's name, description, invocation behavior (on-demand vs proactive), tools, memory setting, workflow steps, and rules. The description field is especially important — it is read by Claude to decide when to invoke the agent, so it must clearly state the trigger conditions and any "do not invoke" constraints. To make Claude invoke the agent proactively without an explicit call, include the word "PROACTIVELY" in the description; otherwise the agent stays on-demand. Once the details are gathered, present a full draft of the AGENT.md content. Ask the user for confirmation and incorporate any requested edits before writing. Finally, write the file to `.claude/agents/<name>/AGENT.md` in the repository and confirm the path.

## File Format

### AGENT.md Frontmatter
```yaml
---
name: <name>
description: <description>
tools: [Tool1, Tool2]
memory: none
---
```

Omit `model` unless the user specifically wants to pin a model tier. Omit `tools` only if the agent should inherit all session tools — otherwise scope it as narrowly as possible to what the agent actually needs. Set `memory: none` unless the agent requires persistent state across conversations, in which case omit the field entirely to enable the default memory directory.

## Writing Style

Write all agent content — workflow steps and rules — as flowing prose paragraphs, not numbered lists or bullet points. Prose keeps intent and reasoning connected across the full workflow, producing better model execution. The only exception is structured reference data like mode tables or command pattern examples that are genuinely tabular or code-like.

## Rules

Always ask scoping questions one at a time and never write any files without explicit confirmation. Keep all agents under 100 lines and use only ASCII characters. Do not generate a Gemini counterpart — agents are Claude Code-specific and have no Gemini equivalent.
