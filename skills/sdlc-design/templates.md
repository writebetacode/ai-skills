# Design Artifact Templates

Read by `sdlc-architect`, which authors every artifact below. Use these structures verbatim: section names, order, and field names are what `/sdlc-implement` and `/sdlc-complete` read back.

`<default-branch>` takes the real branch name resolved at session start, never a literal `main`.

Every artifact is a Markdown file that lints clean: blank lines around every heading, list, and table; a language on every fenced block; one top-level heading; no trailing whitespace; one trailing newline. Do not wrap prose to a column -- line length is the host repo's call. The structures below already satisfy this; keep them that way when filling them in.

## Spec Format

File: `epics/NN-<epic-slug>/spec.md`

```markdown
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

## Plan Format

File: `epics/NN-<epic-slug>/plan.md`

```markdown
# Implementation Plan: <Spec Title>

Source spec: spec.md
Date: <YYYY-MM-DD>

## Approach

<2-4 sentences on overall strategy.>

## Dependency Graph

<default-branch> -> feat/<slug>/01-name -> feat/<slug>/02-name

## Tasks

| Task | Branch | Base | Spec Requirements | Summary | Status |
| --- | --- | --- | --- | --- | --- |
| 01-<name> | <type>/<slug>/01-<name> | <default-branch> | FR-1, FR-2 | <one-line> | Todo |
```

Task Status values: `Todo`, `In Progress`, `Done` (no counts -- counts apply only to epic Status in the manifest).

## Task File Format

File: `epics/NN-<epic-slug>/tasks/NN-<name>.md`

```markdown
# Task NN: <Title>

Branch: <type>/<spec-slug>/NN-<task-name>
Base: <default-branch> OR exactly one prior task branch

## Spec Requirements

- FR-<N>: <quoted requirement text>
- NFR-<N>: <quoted requirement text>

## Description

<2-4 paragraphs on WHAT and WHY, not HOW.>

## Key Files

- path/to/file -- <expected change>

## Acceptance Criteria

1. <Testable outcome>

## Dependencies

<Prior task, or "None (branches from <default-branch>).">
```

## Manifest Format

File: `MANIFEST.md`

```markdown
# Project Manifest: <Project Name>

Created: YYYY-MM-DD  |  Last updated: YYYY-MM-DD

## Status Dashboard

| # | Epic | Phase | Status | Spec | Plan | Blockers |

### Status Values

Spec Ready -> Planned -> In Progress (N/M) -> Complete

## Build Order

## Open Issues

| # | Severity | Issue | Status | Resolution |

## Actionable Now
```
