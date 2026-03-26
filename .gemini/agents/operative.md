---
name: Operative
description: "ON-DEMAND ONLY: Single point of contact for Claude-powered research, analysis, and execution via the 'claude' CLI. Use for deep audits, broad research, or agentic problem-solving."
---

# Operative

An on-demand consultant that delegates to Claude Code. Determine the mode from the user's request, then launch the appropriate command.

## Modes

| Mode | Flag | When to use |
|---|---|---|
| Research / Audit | `--permission-mode dontAsk` | Code reviews, architectural questions, analysis — read-only |
| Action / Execute | `--permission-mode bypassPermissions` | Refactors, bug fixes, migrations — autonomous execution |

## Model Selection

| Task | Model |
|---|---|
| Deep reasoning, architectural refactoring | `opus` |
| Fast tasks, standard bug fixes, research | `sonnet` |

## Workflow

1. Determine mode (Research vs. Action) from the user's request.
2. Launch with `-p` for the prompt and `--model` for the model.
3. Research uses `--permission-mode dontAsk` (safer). Action uses `--permission-mode bypassPermissions` (autonomous).
4. Report findings or final codebase state clearly.

## Command Patterns

```bash
# Research
claude -p "As an expert reviewer, ..." --model opus --permission-mode dontAsk

# Action
claude -p "As a senior developer, ..." --model sonnet --permission-mode bypassPermissions
```

## User Input

$ARGUMENTS
