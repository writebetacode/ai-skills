---
name: sdlc-kickoff
description: Spin up a Claude Code agent team that researches a topic, decomposes findings into dependency-mapped epics, brainstorms each epic in parallel, then validates all output before handing off to sdlc-plan.
---

# SDLC Kickoff

Flow: **[kickoff]** -> research -> decompose -> brainstorm -> review -> plan

Before spawning the team, review the arguments provided. If the feature goal, target users, and key constraints are clear, proceed immediately. If any of these are missing or ambiguous, ask one clarifying question at a time -- no more than three -- until you have enough context to drive autonomous research and spec generation. Once context is gathered, identify two complementary research angles that together cover the topic fully; for example, one angle on technical feasibility and codebase patterns, and another on product scope, user needs, and external solutions.

Verify that `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set in settings.json before proceeding. If it is not set, inform the user and stop -- the team cannot be created without this flag.

## Phase 1: Research

Spawn two research teammates in parallel with model `opus`. All teammates inherit the lead's permission mode, so ensure you are running with full permissions before spawning. Assign each teammate one of the two angles. Each teammate's prompt must instruct them to invoke the `research` skill using the Skill tool -- never paraphrase or replicate its logic -- passing their assigned angle and the full gathered context as the argument. Each teammate must answer every clarifying question the skill raises from context, never surfacing questions to the user. Teammates must follow the research skill's folder structure exactly, writing all output under `plans/research/YYYY-MM-DD-<slug>/` with `index.md`, `questions.md`, `findings/<slug>.md`, and `ai-summary.md` as required. Wait for both to go idle and collect their full output folder paths before proceeding.

## Phase 2: Decomposition

Spawn a single decomposition teammate with model `opus`. Its prompt must instruct it to read all research output from phase 1 and identify every distinct feature area as an epic, regardless of whether it depends on other epics. After listing the epics, the agent must analyze inter-epic relationships and produce a logical dependency graph -- a mapping from each epic to the set of epics that must be completed before it can be planned or implemented. The agent must produce `plans/kickoff-YYYY-MM-DD/epics.md` containing a numbered list of epics, each with a short title, a 2-3 sentence description of its scope, and the relevant research findings that informed it, followed by a `## Dependency Graph` section that maps each epic to its prerequisites. If an epic has no prerequisites it is listed as having none. Wait for this agent to go idle before proceeding. The epic list and dependency graph in this file drive all of phase 3.

## Phase 3: Brainstorm

Spawn one shared research liaison and two brainstorm teammates per epic, all in parallel, with model `opus`. The research liaison's prompt must instruct it to load all phase 1 and phase 2 research output as context and remain active to field questions from any brainstorm agent via team messaging. When a brainstorm agent sends it a question, it must research the answer, append the exchange to the relevant `questions.md` file in the phase 1 research folder, and update or create a `findings/<slug>.md` entry if warranted. The liaison stays active until all brainstorm agents across all epics go idle.

Each pair of brainstorm agents is assigned one epic from `epics.md`. Within each pair, one agent focuses on core feature definition for that epic and the other focuses on edge cases, alternative approaches, and integration concerns. Each brainstorm agent's prompt must include the full dependency graph from phase 2 and instruct them to invoke the `sdlc-brainstorm` skill using the Skill tool, passing their epic description, the relevant phase 1 `ai-summary.md` content, and the dependency graph as seed context. Each produced `spec.md` must include a `## Dependencies` section at the top, listing by title every epic that must be planned and built before this one can begin. If the epic has no prerequisites the section reads "None." When the skill raises a question that cannot be answered from context, the agent must send it to the research liaison via team messaging and wait for the response before continuing. Each spec must be written to `plans/YYYY-MM-DD-<slug>/spec.md` exactly as the brainstorm skill requires, using the epic title as the slug. Wait for all brainstorm agents and the liaison to go idle before proceeding.

## Phase 4: Review

Spawn a single review teammate with model `opus`. Its prompt must instruct it to read all research folders, `epics.md`, and every spec file produced in phase 3, then validate each document against three criteria: it follows the exact file structure and format required by its skill, it addresses its epic scope without drifting into another epic's territory, and it contains no fabricated sources or ambiguous requirements. The reviewer must produce `plans/kickoff-YYYY-MM-DD/review.md` listing each document, its validation status (pass or needs revision), and specific actionable feedback for any issues. Once the reviewer goes idle, clean up the team.

## Handoff

Report all file paths written during the session -- research folders, `epics.md`, spec files, and `review.md` -- so the user can inspect outputs and run `/sdlc-plan` on any spec when ready.

## Rules

Teammates must always use the Skill tool to invoke `research` and `sdlc-brainstorm` -- never inline or replicate skill logic. Every file must be saved to the exact path the invoked skill specifies. Phases are strictly sequential: each phase only starts after all teammates from the previous phase are idle. The research liaison in phase 3 must keep its documents updated with every Q&A exchange. If the experimental teams flag is missing, stop and inform the user rather than falling back to sequential agents.
