---
name: sdlc-brainstorm
description: Turn an idea into one or more specs through guided questioning, with built-in research and automatic multi-epic decomposition when scope demands it.
---

# Brainstorm: From Idea to Spec

Flow: **[brainstorm]** -> plan -> validate -> implement -> complete

If `$ARGUMENTS` is empty, ask what to build. Do not proceed without a substantive prompt.

## Workflow

Begin by reading relevant codebase context -- architecture docs, existing patterns, and files related to the prompt. Engage in iterative questioning, asking only one question at a time to challenge assumptions and push for specific, actionable answers. Respond fully to questions the user asks back and present multiple architectural options with trade-offs when significant choices arise.

When the topic is unfamiliar, technically deep, or answers raise questions the codebase cannot resolve, conduct research inline. Use built-in web search and codebase tools to gather findings. Every finding must cite its actual source -- never fabricate URLs. Write research output to `research/` inside the project folder using the Research Output structure below.

As questioning progresses, monitor whether the scope naturally decomposes into multiple independent work streams with their own dependencies. If it does, propose: "This looks like a multi-epic project -- I'd like to decompose it into N epics." On confirmation, transition to multi-epic mode. If scope stays contained, continue until all aspects are concrete and write a single-epic project.

## Project Structure

Every brainstorm produces a project folder at `plans/YYYY-MM-DD-<slug>/` with a `MANIFEST.md` at its root. The slug describes the initiative scope. Ensure `plans/` is git-ignored before writing any output.

A single-epic project has one epic under `epics/`. Write the spec to `epics/YYYY-MM-DD-<epic-slug>/spec.md`, generate the manifest with one entry at "Spec Ready", and suggest moving to the planning phase.

## Multi-Epic Mode

Write `epics.md` containing a numbered epic list -- each with title, 2-3 sentence scope, and supporting research findings -- followed by a `## Dependency Graph` mapping each epic to its prerequisites. Write `build-plan.md` with phased build order and critical path.

Attempt to create an agent team for parallel brainstorming. If teams are unavailable, fall back to the Agent tool for subagents. Use model `opus` for all spawned agents. Spawn one research liaison that loads all research output and fields questions via messaging, plus two agents per epic -- one for core feature definition writing `spec.md`, one for edge cases writing `edge-cases.md` -- both to `epics/YYYY-MM-DD-<epic-slug>/` under the project folder. Each agent performs the brainstorm questioning process autonomously, answering from context and routing unresolvable questions to the liaison. Every spec includes a `## Dependencies` section listing prerequisite epics by title.

Once all agents complete, run epic validation: verify each spec follows the format, addresses only its epic's scope, contains no fabricated sources, and that cross-epic interfaces are consistent. Write findings to `review.md` in the project root.

Generate `MANIFEST.md` by reading `epics.md`, `build-plan.md`, and `review.md`. Pre-populate all epics at "Spec Ready", the build order, and open issues. End with: "Manifest created. Run `/sdlc-status` to see what's actionable."

## Spec Format

File: `spec.md`

```
# <Title>

Date: <YYYY-MM-DD>
Prompt: "<original prompt>"

## Dependencies
<Epic prerequisites by title, or "None.">

## Problem Statement
<2-4 sentences. No prior context assumed.>

## Scope
### In Scope / ### Out of Scope

## Decisions
<Numbered. **<Topic>**: <Decision>. <Rationale>.>

## Requirements
### Functional Requirements / ### Non-Functional Requirements

## Architectural Context
## Terminology
<Table: Term | Definition | Aliases to avoid.>
## Reference Files
## Open Questions
```

## Manifest Format

File: `MANIFEST.md`

```
# Project Manifest: <Project Name>

Created: YYYY-MM-DD  |  Last updated: YYYY-MM-DD

## Status Dashboard
| # | Epic | Phase | Status | Spec | Edge Cases | Plan | Blockers |

### Status Values
Spec Ready -> Planned -> Validated -> In Progress (N/M) -> Complete

## Build Order
## Open Issues
| # | Severity | Issue | Status | Resolution |
## Actionable Now
```

## Research Output

Root: `research/` inside the project folder. `index.md` contains the topic, summary, TOC, and "Out of Scope" dismissed branches. `questions.md` is the Q&A log with status and links. Each `findings/<slug>.md` covers one area with inline citations and backlinks. `ai-summary.md` synthesizes everything for AI consumption.

## Rules

Ask only one question at a time, proposing codebase-derived answers when possible. Focus specs on what to build, not how. Ensure `plans/` is git-ignored. ASCII only, no AI attribution. Never fabricate sources. Multi-epic phases are strictly sequential: research before decomposition, decomposition before parallel brainstorming, brainstorming before review.

## User Input

$ARGUMENTS
