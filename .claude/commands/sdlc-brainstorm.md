---
name: sdlc-brainstorm
description: Generate a complete specification from an initial idea through iterative one-at-a-time questioning. Use when starting a new feature, change, or project and need a spec before planning or implementation.
model: opus
---

# Brainstorm: Generate Specification from Prompt

Flow: **[brainstorm]** → plan → validate → implement → complete

If `$ARGUMENTS` is empty, ask what to build. Do not proceed without a substantive prompt.

## Workflow

1. **Read context**: Read CLAUDE.md/.cursorrules/AGENTS.md and docs/architecture.md if present.
2. **Investigate**: Search for code relevant to the prompt. Do not read the entire repo. Record file paths and findings to pre-fill answers and include as references. If a bug, trace the code path, check recent changes, and identify root cause before questioning.
3. **Question one at a time**: Challenge assumptions, reject vague answers, push for specifics. Propose codebase-derived answers for confirmation. If the user asks a question back, answer it fully before resuming. For significant architectural choices, present 2-3 meaningfully different options and discuss trade-offs before committing to one. Do not move on until the answer is concrete and actionable. Continue until nothing is ambiguous.
4. **Write spec**: Ensure `plans/YYYY-MM-DD-<slug>/` exists and `plans/` is in `.gitignore`. Write the spec file.

## Spec Format

File: `plans/YYYY-MM-DD-<slug>/spec.md`

```
# <Title>

Date: <YYYY-MM-DD>
Prompt: "<original prompt from $ARGUMENTS>"

## Problem Statement
<2-4 sentences. No prior context assumed.>

## Scope
### In Scope
<bullets>
### Out of Scope
<bullets>

## Decisions
<Numbered. **<Topic>**: <Decision>. <Rationale>.>

## Requirements
### Functional Requirements
<Numbered>
### Non-Functional Requirements
<Numbered — omit if none>

## Architectural Context
<Layers affected, packages involved, connections.>

## Terminology
<Table: Term | Definition | Aliases to avoid. Domain terms only — skip generic programming concepts. Flag any terms used ambiguously during questioning.>

## Reference Files
<bullets: path -- why relevant>

## Open Questions
<Unresolved questions, or "None.">
```

## Rules

- One question at a time — never batch
- Propose codebase-derived answers for confirmation
- Spec defines WHAT, not HOW — no implementation plans
- `plans/` in .gitignore
- ASCII only, no AI attribution

Suggest `/sdlc:plan` when done.

## User Input

$ARGUMENTS
