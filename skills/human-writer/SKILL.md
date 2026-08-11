---
name: human-writer
description: Draft or tighten writing that other people have to read -- summaries, updates, announcements, docs, chat and email -- against a named audience and a length budget. Use when writing something for someone else to read, when a draft has grown longer than its reader will get through, when asked to shorten, tighten, or make something scannable, or when the point is buried and the piece needs to lead with it. Never for specs, plans, task files, ADRs, or research notes, which are meant to be complete rather than short.
argument-hint: "[what to write, or the text or path to tighten]"
---

# Human Writer

Every piece here has a reader who is not you and will not finish it. The job is to get that reader to the thing they came for.

## Workflow

Settle three things before writing a word: who reads it, what they already know, and what they do or decide next. The request usually names some -- take those from it and ask only for what is left, one at a time. Where the piece is one of the rows below and the request states no budget of its own, take the budget from the table rather than asking for it.

Then draft, or cut an existing draft to fit. A tighten run hands back the shorter version and names what it dropped, since the author is the one who knows whether a cut sentence was load-bearing.

A body one of the forge skills owns -- a PR description, an issue body, release notes -- is written or revised by that skill rather than here. Each carries its own template and its own cap already, and a PR body composed here arrives without the fence markers `/pr` needs to find its own region on the next update.

## Budgets

| Piece | Budget |
| --- | --- |
| Chat message or email | the ask in the first two lines, five lines total |
| Status update or announcement | one sentence of context, then one line per item |
| Summary of a document, thread, incident, or change | five sentences |
| Reference doc a reader returns to | no length cap -- a heading every screen, one idea per paragraph |

A budget the request states outright replaces the row it lands on.

## Rules

Lead with what the reader does or decides; context follows it. A reader who stops after the first two lines still has the thing they came for.

One idea per sentence, one claim per bullet. Cut every sentence that only restates the one before it, every hedge that does not change the claim -- "it seems", "arguably", "generally speaking" -- and every preamble announcing what the next paragraph is about to say.

Name the thing rather than describing it: the file, the function, the number, the date, the person who owns it. A specific noun is shorter than the phrase that gestures at it.

Prose where the ideas connect, bullets where they enumerate, and never a bullet nested more than one level deep.

**Cut violation:** meeting a budget by dropping what the reader needs rather than what the writer added. Cutting "after a fairly thorough investigation it turns out that" is the acceptable form; cutting the rollback step, the deadline, or the one caveat that changes the decision is the violation. Where everything left is load-bearing, say the budget does not fit and hand back the shortest honest version rather than a version that fits and misleads.

**Scope violation:** tightening a spec, plan, task file, ADR, or research document -- anything under `plans/` or `docs/adrs/`, and anything `/sdlc-design` authored. Those are written to be complete rather than short, and a reader opens one for exactly the detail this skill exists to remove. Tightening an announcement that summarizes a spec is acceptable; tightening the spec is the violation.

Restrict generated output to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
