---
name: research
description: Deep-dive research phase that compiles sourced findings into a structured brief before brainstorming. Use before sdlc-brainstorm when the topic benefits from external research or codebase archaeology.
---

# Research: Deep-Dive Before Brainstorm

Flow: **[research]** -> brainstorm -> plan -> validate -> implement -> complete

If `$ARGUMENTS` is empty, ask what to research. Do not proceed without a substantive topic or question.

## Workflow

Begin by reading relevant context from the codebase -- architecture docs, existing patterns, and related files -- while simultaneously seeding an initial set of research questions from the prompt. Use Claude's built-in web search and codebase tools as the default research engine. When a question is broad, deeply technical, or would benefit from wider web coverage, spawn the Gemini Operative as a sub-agent in parallel with other active research threads rather than waiting for each to complete sequentially.

As research progresses, treat each distinct line of inquiry as a branch. Follow promising branches by generating follow-up questions and deepening findings. When a branch proves irrelevant, too speculative, or outside the defined topic, log it to the "Out of Scope" section of `index.md` with a one-line rationale and stop pursuing it. Continue branching and pruning until the topic is well-covered and no high-value threads remain open.

Every claim, fact, or finding must link back to its actual source -- never fabricate or guess URLs. For web sources, use the real URL returned by search. For codebase sources, reference the specific file path along with any relevant branch, PR number, tag, or commit SHA to scope the reference precisely. Once research is complete, synthesize all findings into `ai-summary.md` as a compact digest optimized for AI consumption, then suggest moving to the brainstorm phase.

## Folder Structure

Root: `plans/research/YYYY-MM-DD-<slug>/`

`index.md` is the entry point: it contains the topic, a brief summary, a table of contents linking every findings doc and the questions log, and an "Out of Scope" section listing dismissed branches with one-line rationale for each.

`questions.md` is the running Q&A log. Each entry records the question, its status (open or answered), and a direct link to the findings doc that resolves it.

Each `findings/<slug>.md` covers one research area. It contains a summary, full details with inline source citations, a sources section listing every URL or codebase reference used, and backlinks to the questions it answers. Codebase references must include file path and at minimum one of: branch, PR, tag, or commit SHA.

`ai-summary.md` synthesizes all findings into a fast-consumption digest: key takeaways, patterns, and recommended starting points for the brainstorm session. Each point links back to the relevant findings doc.

## Rules

Never fabricate source links -- only include URLs actually returned by search tools or confirmed to exist in the codebase. Spawn Gemini Operative as a sub-agent in parallel whenever deep web research would benefit a thread; never block other research threads waiting for it. Keep each file focused on one research area -- no mega-files. Always add `plans/` to `.gitignore` before writing any output. Use only ASCII characters and include no AI attribution in any file.
