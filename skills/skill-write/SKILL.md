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

Place at `skills/<name>/SKILL.md` relative to repo root. Each skill ends with `## User Input\n\n$ARGUMENTS`. A skill that carries a `## Response Style` section MUST precede it with the response-style marker comment and copy the block byte-identically from an existing tagged skill — `task verify:response-style` checks only marked files, so an unmarked copy drifts silently while a marked copy with edited text fails the build. Copy both marker and block from a tagged skill rather than retyping either. A single file serves both Claude Code and Gemini CLI — `task install` symlinks it into `~/.claude/skills/` and `~/.gemini/skills/`. The `description` is how the model decides when to invoke — state the concrete trigger ("Use when the user wants to …") and, where ambiguity is likely, when to skip.

## Writing Style

Write all skill content — workflow, rules, explanations — as flowing prose paragraphs, not numbered lists or bullets. Prose keeps intent and reasoning connected; bullets fragment context and strip causal connectives. Exception: structured reference formats like templates or tabular/code-like examples.

## Token Efficiency

Skills sit in system context and are paid for on every invocation. Before writing or cutting any sentence, classify it.

**Derivable — leave it out.** Behavior a current model produces from the task itself: rationale for a rule it would follow anyway, explanations of why an approach is correct, restatements of a constraint already stated elsewhere in the same file, step-by-step sequencing of an obvious procedure, defensive hedging against mistakes these models do not make. Current models do not need to be told to work carefully or to be walked through inferable steps.

**Specification — keep verbatim.** Anything the model cannot derive because it is a fact about this setup or an arbitrary choice: exact templates and their section order, literal commands and flags, tool and agent names, file paths and naming schemes, message and JSON contracts, status vocabularies, numeric thresholds, and every safety constraint on a destructive or irreversible operation. Preserve these word for word; never paraphrase a command or reorder a template.

Two constraints on the cut. When a sentence is genuinely ambiguous between the categories, keep it — losing capability costs more than the tokens save. And when Workflow and Rules would state the same constraint twice, state it once, in whichever section makes it likelier to be followed; for destructive operations that means the imperative-negative form in Rules ("Never delete without..."), even at the cost of the Workflow line.

## Updating Existing Skills

When updating rather than creating, read the current file first and diff proposed changes. Explicitly list any functionality that would be removed and confirm each removal before writing. Never drop behavioral details silently — every step, rule, and constraint must be preserved or explicitly approved for removal. Cutting derivable prose is not a removal and needs no per-edit confirmation, as long as every specification item survives intact. Do not treat a prior commit message claiming the file was already tightened as evidence; verify against the file.

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Always ask scoping questions one at a time; never write files without explicit confirmation. Place each skill in its own subdirectory under `skills/` at the repo root. After writing, update README.md to include the new skill in the appropriate table, then run `task install && task verify` and confirm both exit 0. Keep skills under 100 lines; the only exception is an orchestration skill whose embedded document templates are load-bearing (e.g. sdlc-design). Use only ASCII; never include AI attribution or "Co-Authored-By" lines. Prefer dedicated tools over shell commands in generated workflow text (Read/Edit/Write/Glob/Grep over `cat`/`sed`/`find`/`rg`) so skills read the same way the host CLIs execute them.

## User Input

$ARGUMENTS
