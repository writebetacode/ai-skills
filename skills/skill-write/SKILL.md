---
name: skill-write
description: Author or revise any file under skills/ or agents/ in this repo -- SKILL.md, AGENT.md, and the reference files and templates beside them -- covering scoping questions, the frontmatter contract, the description rules that decide whether a skill ever fires, and the token-efficiency and progressive-disclosure rules that decide what earns a place in the file. Use when codifying a repetitive task into a skill, a specialized role into an agent, when editing any of those files however small the change looks, when changing a template or format that other files read back, when a skill triggers on the wrong prompts, or when one has grown long enough to be worth splitting.
argument-hint: "[what to write or revise]"
---

# Skill Write

## Workflow

Establish which artifact is being written first -- frontmatter, output path, and questions all differ. Where the conversation already contains the workflow being codified, take the steps, tool names, and corrections from it and confirm them, rather than asking cold for what is already on screen. Scope the rest by asking name, description, workflow steps, rules, and for an agent its tools, model, and effort. Then write the file and run `task install && task verify && task lint:md`, confirming all three exit 0 -- `lint:md` sits outside `verify` because it needs the network, so it never runs unless it is named. Close by reading back what the change added and checking it against the rules below: every other check here is aimed at what a change removed, so nothing but this pass looks at the new text.

Update the docs in the same change. `CLAUDE.md` names which of the four owns what; a new skill or agent always touches `README.md`'s table plus whichever document covers its behaviour.

## File Format

`skills/<name>/SKILL.md`, ending with `## User Input` and the arguments token -- `ARGUMENTS` in dollar form. One file serves Claude Code and Gemini CLI both. The directory name is what the slash command resolves from; keep the `name` field equal to it, since `name` sets only the label shown in listings and a mismatch means the command and the listing disagree.

```yaml
---
name: <name>
description: <what it does, then "Use when ...">
argument-hint: "<[thing] the skill expects, omitted when it takes none>"
---
```

Quote `argument-hint`. Unquoted, `[x]` is a YAML flow sequence rather than a string, and `[x] [y]` does not parse at all -- taking the whole frontmatter down with it, so the skill loses its description and its trigger rather than just its hint.

`agents/<name>/AGENT.md`, no `## User Input` section, Claude Code only.

```yaml
---
name: <name>
description: <what it does, then who invokes it and what it must never decide>
tools: [Tool1, Tool2]
model: <opus | sonnet | haiku>
effort: <low | medium | high | xhigh | max>
---
```

Agents pin `model` and `effort` because they spawn cold with no session to inherit from. Weigh the model by task -- `opus` for design, architecture, and judgment; `sonnet` for routine coding and mechanical dispatch; `haiku` for read-only lookups -- and `effort` by reasoning load, `high` for most work, `xhigh` or `max` for subtle correctness. Omit `memory` entirely: its only values are `user`, `project`, and `local`, all of which persist a directory across sessions, and every agent here is spawned per task and re-reads its inputs. Scope `tools` narrowly; omit only to inherit every session tool. Withholding a tool is a real constraint, stronger than an instruction: an agent with no `Write` cannot author the payload it forwards.

Give an agent a one-line Identity -- the disposition it argues from when a call is close.

The spec carries fields this repo declines, and recording the decision is what stops it being re-argued as an oversight. Every skill here stays model-invocable rather than taking `disable-model-invocation`, because each already guards its own side effects and a user-only skill drops its description from context entirely, which is the one thing that decides whether it is ever reached. The arguments token covers what these skills take, so `arguments` and its named placeholders go unused. `skills:` preloads a whole `SKILL.md` into an agent at spawn, which suits an agent needing a skill's body rather than the reference file beside it -- not the case here, where the architect wants `templates.md`. `hooks`, `paths`, `shell`, `isolation`, and `color` earn nothing yet.

`skills/<name>/<file>.md` for a reference file: no frontmatter, since it is not a skill and has no `name` to resolve. Open with one top-level heading and a lead line naming who reads it and what that reader already has loaded, so the file carries only what its own context lacks.

## Triggering

The description is the only part loaded before a skill fires, so it decides whether the skill is consulted at all and the body never gets a vote. Write it in two halves: what the skill does, then the contexts that should reach for it, in the words a user would type rather than the ones the skill uses internally. Skills under-fire far more often than they over-fire, so state the trigger wider than feels necessary and cover the prompts that describe the goal without naming the artifact.

A description competes with its siblings, not with silence. Before calling one done, write three or four prompts a real user would type -- including near-misses belonging to a neighbouring skill -- and check that the description sorts them. Siblings acting on the same object are where this bites: where one skill drafts a document and another publishes it, "get this ready to go out" has to land on exactly one, and it does so only because each description claims a verb the other never uses. A prompt that lands in both is fixed in the description, not left for the model to break the tie.

## Token Efficiency

Skills and agents are paid for on every invocation. Classify each sentence before writing or cutting it.

**Derivable -- leave it out.** What a current model produces from the task itself: rationale for a rule it would follow anyway, why an approach is correct, a constraint already stated elsewhere in the same file, step-by-step sequencing of an obvious procedure, hedging against mistakes these models do not make.

**Specification -- keep verbatim.** What cannot be derived because it is a fact about this setup or an arbitrary choice: templates and their section order, literal commands and flags, tool and agent names, paths and naming schemes, message and JSON contracts, status vocabularies, thresholds, and every constraint on a destructive or irreversible operation. Never paraphrase a command or reorder a template.

Rationale is not automatically derivable. Keep the sentence that resolves a case the rules do not list, or that sets the stake so a reader knows to stop rather than warn; cut the one that only re-explains a rule already given.

Keep anything genuinely ambiguous between the categories -- losing capability costs more than the tokens save. Where one constraint could sit in either Workflow or Rules, put it where it is likelier to be followed; for a destructive operation that is the imperative-negative in Rules.

## Progressive Disclosure

A skill's body loads whole on every invocation; a sibling `<name>.md` loads only when something reads it. Splitting one out trades tokens for a `Read` round-trip and the chance the model skips it and works from memory instead, so it pays only where a real path never reaches the block. Two gates open it and either is enough -- apply it wherever one does, and inline everything else.

**Cross-context.** The context that loads the skill is not the one that uses the block. A skill whose main thread only routes -- forbidden by its own rules from authoring, delegating that to an agent -- pays for every template line it carries and fills in none of them, while the agent that does reads the whole `SKILL.md` to find them. A skill naming its own sibling points at `CLAUDE_SKILL_DIR` -- the variable in dollar-and-braces form -- followed by `/<file>.md`, which Claude Code expands to wherever the skill is installed. Never spell that token out literally in this file: the runtime substitutes it here too, turning an instruction about any skill into a hardcoded path to this one. An agent gets no such substitution and needs the literal `~/.claude/skills/<name>/<file>.md`. Either way a repo-relative path resolves nowhere but the repo it was written in.

**Selective bulk.** A block of roughly 1k tokens or more that a named mode never reaches -- one you can name, not one that might skip it. Measure before splitting: `wc -c` over the section, bytes over four. Under that floor the pointer prose and the round-trip eat the saving.

Length alone opens neither gate. Check whether a section is derivable before extracting it, since cutting beats deferring, and never defer a block that has to be reproduced byte-exact -- a skipped read becomes a reconstruction from memory, which is what a verbatim format cannot survive.

`task install` links every `*.md` beside `SKILL.md` and mirrors a `scripts/` or `assets/` directory beneath it, so a reference file is a flat `<name>.md` sibling and an executable belongs in `scripts/`. Reach a bundled script through that same variable plus `/scripts/<name>`, and pre-approve that exact path in `allowed-tools`, so repeated deterministic work runs without a prompt rather than being retyped as a command each time. An agent has no equivalent -- only `AGENT.md` is linked -- so neither gate opens for one: it carries what it needs in that file, or reads an installed skill's reference file at `~/.claude/skills/<name>/<file>.md`.

Duplication between two files costs nothing at runtime, because skills load one at a time. Never split a file to remove text another file repeats -- the only cost is editing twice, and a shared file that must be read back is worse.

## Writing Style

Prose paragraphs, not bullets: bullets fragment context and strip the connectives that carry intent. Tables and code blocks are the exception, and are the right form for command references and templates.

State a hard constraint as a violation clause rather than as plain prose, in the shape the Clause violation below fixes. Examples are specification; they settle the boundary that prose leaves soft.

Write standing instructions, not steps to perform once. A rendered body enters the conversation as a single message and stays for the session, and Claude Code never re-reads the file on a later turn, so a rule phrased as work to do now stops applying the moment it is done. An `allowed-tools` grant is the exception that shows the shape: permissions clear on the next message while the instructions do not.

Define the failure paths. A skill that forbids a fallback but never says what to do when its dependency is absent leaves nothing between a forbidden workaround and a dead stop, and the workaround is what happens.

Transcribe commands from the CLI itself, never from memory. Where a binary was unavailable and a published reference was used instead, say so in the file and instruct reporting the tool's own error rather than substituting a flag that looks close.

## Updating

Read the current file first, and account for every behaviour the change removes -- name each one when reporting the change, so a removal is surfaced rather than discovered later. Cutting derivable prose is not a removal, as long as each specification item survives.

After an edit that was meant to shorten, diff the rule-bearing sentences -- `never`, `must`, `always`, `violation:` -- against the original and account for every one that disappeared. Reworded is fine, relocated into a violation clause is fine, gone is a bug. Never take a commit message claiming a file was already tightened as evidence; check the file.

## Rules

Always ask scoping questions one at a time, and keep asking until nothing material is unsettled. Write the file once it is, without pausing for approval of the draft.

Target 100 lines, counting everything outside the frontmatter, tables, and fenced blocks. Past that, check whether a section is derivable, then whether a gate in Progressive Disclosure opens, before deciding the skill is genuinely large.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Clause violation:** a violation clause turning on a judgment call that shows only what is forbidden. Where what counts is binary -- a finding without a number, a `model` key in a SKILL.md -- the label and the rule settle it and examples are derivable. Where it turns on reading an order, a diff, or a request, both halves are load-bearing: "running `merge` the order did not name" leaves a legitimate order looking equally refusable until "an order reading `op: merge` with `--squash` is run as written" is there beside it.

**Restatement violation:** a Role section paraphrasing the frontmatter description, which loads with the body anyway, or any constraint stated in both Workflow and Rules.

**Model violation:** a `model` or `effort` key in a SKILL.md, or an AGENT.md pinning `model` without `effort`. The skills spec permits both on a skill and this repo declines them, so invoking one never changes the tier or the cost of the session it runs in; that is a house rule rather than a platform limit, and the reason has to travel with it or someone reinstates the key on the grounds that the spec allows it.

**Trigger violation:** a description that stops at what the skill does, or that names the artifact without the intent someone would arrive with. "Create a conventional commit from staged changes" alone is a violation, since nothing in it claims the prompt "commit this"; the same sentence followed by "Use when the user wants to commit staged changes with a properly formatted commit message" is acceptable.

**Contract violation:** renaming, reordering, or removing a section or field another file reads back by name, without following every reader in the same change. `templates.md`'s `## Acceptance Criteria` is read by `/sdlc-implement` and compared by a signoff gate, so renaming it there alone is a violation; adding a section no reader indexes, or rewording the prose inside one, is not.

**Substitution violation:** the arguments token or `CLAUDE_SKILL_DIR` written literally in body prose, where the runtime replaces it before anything reads the file, so a sentence about the token renders as the user's own prompt or as a path to whichever skill is loaded. Name either descriptively where a rule is about it, and write it literally only where the substitution is the point -- the arguments token in the final `## User Input` section, `CLAUDE_SKILL_DIR` in a path the skill actually reads.

**Disclosure violation:** extracting a block every path through the skill reads, or pointing a cross-context reader at a repo-relative path rather than the installed one. Splitting out a body template the skill fills in itself is a violation, since the context that composes the body is the one that loaded the template; splitting out templates a delegated agent fills in is acceptable, since the context that loads them is forbidden from using them.

## User Input

$ARGUMENTS
