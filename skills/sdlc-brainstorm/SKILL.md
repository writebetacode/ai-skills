---
name: sdlc-brainstorm
description: Turn an idea into one or more specs through guided questioning, with built-in research and automatic multi-epic decomposition when scope demands it.
---

# Brainstorm: From Idea to Spec

Flow: **[brainstorm]** -> plan -> validate -> implement -> complete

If `$ARGUMENTS` is empty, ask what to build. Do not proceed without a substantive prompt.

## Workflow

Begin by reading relevant codebase context -- architecture docs, existing patterns, and files related to the prompt. Engage in iterative questioning, asking only one question at a time to challenge assumptions and push for specific, actionable answers. Respond fully to questions the user asks back and present multiple architectural options with trade-offs when significant choices arise.

When the topic is unfamiliar, technically deep, or answers raise questions the codebase cannot resolve, conduct research inline. Use built-in web search and codebase tools to gather findings. Every finding must cite its actual source URL -- never fabricate or guess URLs. Before including any URL, verify it resolves successfully. Write research output to `research/` inside the project folder: an index with topic and TOC, a Q&A log, individual findings files with inline citations, and an AI summary.

As questioning progresses, monitor whether the scope naturally decomposes into multiple independent work streams with their own dependencies. If it does, propose: "This looks like a multi-epic project -- I'd like to decompose it into N epics." Continue questioning until all aspects are concrete, then move to spec creation.

## Project Structure

Every brainstorm produces a project folder at `plans/YYYY-MM-DD-<slug>/` with a `MANIFEST.md` at its root. The slug describes the initiative scope. Ensure `plans/` is git-ignored before writing any output.

## Spec Creation

Once questioning is complete, write `epics.md` containing a numbered epic list -- each with title, 2-3 sentence scope, and supporting research findings -- followed by a `## Dependency Graph` mapping each epic to its prerequisites and a `## Build Order` with phased build order and critical path. A single-feature brainstorm produces an `epics.md` with one entry and no dependencies.

Then spin up an agent team with model `inherit` to produce specs. The team structure is the same for single-epic and multi-epic -- only the number of spec-creators varies.

The **researcher** loads all prior research output and codebase context, fields factual questions from other agents, and gathers additional findings via web search when needed. Every URL the researcher provides must be verified as reachable -- never pass along a URL without confirming it resolves. The **architect** reads the research output and epic decomposition, then writes an architecture brief covering shared interfaces, data contracts, naming conventions, and cross-cutting technology choices. Spec-creators do not begin until the brief is ready. The architect stays live to answer structural questions and updates the brief when new decisions emerge. The **validator** runs concurrently from the start, checking each completed spec against the architecture brief, the spec format, and other specs for scope overlap, interface mismatches, fabricated sources, and missing sections. It messages the relevant spec-creator and architect to resolve issues immediately -- only genuinely unresolvable items requiring human decision are recorded as open issues in the manifest. Each **spec-creator** (one per epic) writes a complete `spec.md` to `epics/YYYY-MM-DD-<epic-slug>/`, answering from context and routing factual questions to the researcher and structural questions to the architect. Every spec includes a `## Dependencies` section listing prerequisite epics by title.

Generate `MANIFEST.md` by reading `epics.md` and the completed specs. Pre-populate all epics at "Spec Ready", the build order, and any open issues the validator could not resolve. End with: "Manifest created. Run `/sdlc-status` to see what's actionable."

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

## Edge Cases
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
| # | Epic | Phase | Status | Spec | Plan | Blockers |

### Status Values
Spec Ready -> Planned -> Validated -> In Progress (N/M) -> Complete

## Build Order
## Open Issues
| # | Severity | Issue | Status | Resolution |
## Actionable Now
```

## Rules

Ask only one question at a time, proposing codebase-derived answers when possible. Focus specs on what to build, not how. Ensure `plans/` is git-ignored. Never fabricate sources or URLs. Phases are strictly sequential: research before decomposition, decomposition before architecture brief, brief before parallel spec creation. Use only ASCII characters in all generated content and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
