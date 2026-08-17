---
name: human-writer
description: Draft or tighten writing that other people have to read -- summaries, updates, announcements, docs, chat and email -- against a named audience and a length budget. Use when writing something for someone else to read, when a draft has grown longer than its reader will get through, when asked to shorten, tighten, or make something scannable, when the point is buried and the piece needs to lead with it, when a draft reads as harsh, blunt, or accusatory and needs to land warmer without losing what it says, or when writing or reworking documentation -- a README, a guide, a runbook, an onboarding page -- that has to make sense to someone who has not seen the thing before. Never for specs, plans, task files, ADRs, or research notes, which `/sdlc-design` owns.
argument-hint: "[what to write, or the text or path to tighten]"
---

# Human Writer

Every piece here has a reader who is not you and will not finish it. The job is to get that reader to the thing they came for, and to leave them willing to open the next one.

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

## Documentation

A doc is the piece that fails by omission rather than by length. Its reader arrives mid-problem, often from a search result, holding none of the context the writer has and none from any other page. Write for the least informed reader who could legitimately land there.

Open by orienting: what the thing is, who it is for, what it does for them, and what it assumes is already in place -- installed, running, configured, or read. How it works comes after that. Leading with the action inverts here, because a reader who does not yet know what they are looking at cannot act on a first line telling them to.

Define a term the first time the doc uses it, this project's invented ones included, and expand an acronym on first use. Every page stands on its own: link to what came before rather than assuming it, and repeat the one sentence the reader needs rather than sending them elsewhere for it. A repeated sentence costs less than a reader who leaves to find it.

Show the real thing -- a command that runs as written, a payload with the actual field names, the output it prints -- and say what the reader sees when it worked, and what they see when it did not.

**Assumed-context violation:** explaining how before the reader knows what and why, or resting on knowledge the doc neither gave them nor pointed at. Opening a caching page with "Set `ttl` in the config" is the violation; naming what the cache is for and what it needs running, then setting `ttl`, is the acceptable form. Squeezing a doc to a length budget is the same violation from the other side -- the cut rules below take padding out of a doc, never a fact.

## Rules

Lead with what the reader does or decides; context follows it. A reader who stops after the first two lines still has the thing they came for.

One idea per sentence, one claim per bullet. Cut every sentence that only restates the one before it, every hedge that blurs a claim without changing it -- "it seems", "arguably", "generally speaking" -- and every preamble announcing what the next paragraph is about to say. The words that make a request land as a request are not hedges: "could you", "when you get a chance", "I think" survive the cut, because a request stripped to its bare verb arrives as an order rather than an ask.

Name the thing rather than describing it: the file, the function, the number, the date, the person who owns it. A specific noun is shorter than the phrase that gestures at it. Name a person for what they own or what they do next; where a person is the cause of the problem, name the problem instead, since what the reader needs is the thing that broke and the name adds only a target.

Prose where the ideas connect, bullets where they enumerate, and never a bullet nested more than one level deep.

**Tone violation:** a sentence the reader would hear as blame, correction, or condescension where the same fact states neutrally. "The migration failed at 14:02 and rolled back" is the acceptable form; "the migration you shipped broke prod" is the violation, and so are "as I already mentioned", "you failed to", "this should have been caught", and the words that leave a reader feeling slow -- "obviously", "just", "simply", "actually". Neutral is the floor and warmth is welcome above it. What is never available is buying the tone with accuracy: the deadline slipped, the proposal was rejected, the number was wrong, each still said plainly in the sentence that no longer says whose fault it was.

**Cut violation:** meeting a budget by dropping what the reader needs rather than what the writer added. Cutting "after a fairly thorough investigation it turns out that" is the acceptable form; cutting the rollback step, the deadline, or the one caveat that changes the decision is the violation. Where everything left is load-bearing, say the budget does not fit and hand back the shortest honest version rather than a version that fits and misleads.

**Scope violation:** tightening a spec, plan, task file, ADR, or research document -- anything under `plans/` or `docs/adrs/`, and anything `/sdlc-design` authored. Those are written to be complete rather than short, and a reader opens one for exactly the detail this skill exists to remove. Tightening an announcement that summarizes a spec is acceptable; tightening the spec is the violation.

Restrict generated output to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
