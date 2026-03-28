---
name: sdlc-brainstorm
description: Generate a complete specification from an initial idea through iterative one-at-a-time questioning. Use when starting a new feature, change, or project and need a spec before planning or implementation.
model: opus
---

# Brainstorm: Generate Specification from Prompt

Flow: **[brainstorm]** → plan → validate → implement → complete

If `$ARGUMENTS` is empty, ask what to build. Do not proceed without a substantive prompt.

## Workflow

Begin by reading relevant context from the codebase, focusing on architectural documentation and existing patterns. Search for code related to the user's prompt to record key findings and identify any root causes if the task involves a bug. Engage in an iterative questioning process, asking only one question at a time to challenge assumptions and push for specific, actionable answers. Respond fully to any questions the user asks back and present multiple architectural options with trade-offs when significant choices must be made. Continue this process until all aspects of the feature or fix are concrete and no ambiguity remains. Finally, ensure the plan directory exists and is properly ignored by git before writing the complete specification file.

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

Always ask only one question at a time and propose codebase-derived answers for user confirmation whenever possible. Focus the specification on defining exactly what needs to be built rather than how to implement it. Ensure the `plans/` directory is added to the `.gitignore` and that all outputs are in ASCII without any AI attribution. Once the specification is complete, suggest moving to the planning phase.

## User Input

$ARGUMENTS
