# Agents

Agents live in `agents/` and are Claude Code only.

| Agent | Model | Effort | Description |
|---|---|---|---|
| `sdlc-architect` | opus | xhigh | Design-phase architecture, intake, research, and document authoring for the SDLC flow; owns specs, plans, tasks, MANIFEST and enforces stack-linearity and NN-ordering. SDLC-only |
| `sdlc-tester` | sonnet | high | TDD discipline — red-first batches and full-suite reruns — for the SDLC flow; reworks drift reported by the coordinator's third-party validator. SDLC-only |
| `sdlc-coder` | sonnet | high | Smallest-diff implementation specialist for the SDLC flow. SDLC-only |

## Lifecycle

`sdlc-architect` is spawned by `/sdlc-design` once per design session; `sdlc-tester` and `sdlc-coder` by `/sdlc-implement` once per task. Each is launched via the `Agent` tool (`subagent_type` set to the agent's name) and resumed thereafter with `SendMessage` addressed to that same name, which restores its full transcript — that persistence is what lets the tester write batch 2 knowing what batch 1 revealed. The architect owns research and document authoring inline. Each SDLC agent carries a one-line signature phrase that restates its hardest rule.

## Why agents pin a model

Unlike skills, agents pin `model` and `effort`: they spawn as fresh processes with no session to inherit from, so the tier is part of the role definition.

Tester and coder run on `sonnet` — writing table-driven tests against a written spec and greening them with the smallest diff is routine coding, and the batched TDD loop is the flow's dominant token cost. Judgment-heavy roles stay on `opus`: the architect, and the one-shot spec-vs-code validator `/sdlc-implement` spawns.
