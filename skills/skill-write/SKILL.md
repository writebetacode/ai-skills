---
name: skill-write
description: Author or revise any file under skills/ or agents/ in this repo -- SKILL.md, AGENT.md, and the reference files and templates beside them -- covering scoping questions, the frontmatter contract, the description rules that decide whether a skill ever fires, and the token-efficiency and progressive-disclosure rules that decide what earns a place in the file. Use when codifying a repetitive task into a skill, a specialized role into an agent, when editing any of those files however small the change looks, when changing a template or format that other files read back, when a skill triggers on the wrong prompts, or when one has grown long enough to be worth splitting.
argument-hint: "[what to write or revise]"
---

# Skill Write

## Workflow

First establish which artifact you're writing, since the frontmatter, output path, and questions all differ. If the conversation already contains the workflow being codified, take the steps, tool names, and corrections from it and confirm them instead of asking cold. Scope the rest by asking for the name, description, workflow steps, rules, and, for an agent, its tools, model, and effort. Then write the file and run `task install && task verify && task lint:md`, confirming all three exit 0. `lint:md` isn't part of `verify` because it needs the network, so it only runs if you name it. Finish by reading back what the change added and checking it against the rules below. Every other check here looks at what a change removed, so this is the only pass that looks at the new text.

Update the docs in the same change. `CLAUDE.md` says which of the four documents owns what. A new skill or agent always touches `README.md`'s table plus whichever document covers its behaviour.

## File Format

`skills/<name>/SKILL.md`, ending with `## User Input` and `\$ARGUMENTS`. One file serves both Claude Code and Gemini CLI. The slash command resolves from the directory name, and `name` only sets the label shown in listings, so keep `name` equal to the directory name or the command and the listing disagree.

```yaml
---
name: <name>
description: <what it does, then "Use when ...">
argument-hint: "<[thing] the skill expects, omitted when it takes none>"
allowed-tools: "<Bash rules for the skill's read-only commands, omitted when it has none>"
---
```

`allowed-tools` pre-approves tools; it never restricts them. Unlisted tools stay callable under the session's own permission rules. The grant lasts only for the turn that invoked the skill and clears on the user's next message, so it suits a skill's opening reconnaissance (auth, view, diff, list), not the writes a later turn asks for. Grant the narrowest prefix that matches what the skill actually runs, down to the arguments where the command is fixed, and never a bare tool name. Leave out any operation the body never names. A broad rule like `Bash(jq:*)` matches a redirect as easily as the pipeline it was added for.

Quote `argument-hint`. Unquoted, `[x]` is a YAML flow sequence, and `[x] [y]` doesn't parse at all, which breaks the whole frontmatter: the skill loses its description and trigger, not just its hint.

`agents/<name>/AGENT.md` has no `## User Input` section and is Claude Code only.

```yaml
---
name: <name>
description: <what it does, then who invokes it and what it must never decide>
tools: [Tool1, Tool2]
model: <opus | sonnet | haiku>
effort: <low | medium | high | xhigh | max>
---
```

Agents pin `model` and `effort` because they spawn cold with no session to inherit from. Choose the model by task: `opus` for design, architecture, and judgment; `sonnet` for routine coding and mechanical dispatch; `haiku` for read-only lookups. Choose `effort` by reasoning load: `high` for most work, `xhigh` or `max` for subtle correctness. Leave out `memory` entirely. Its only values (`user`, `project`, `local`) all persist a directory across sessions, and every agent here is spawned per task and re-reads its inputs. Scope `tools` narrowly, and omit it only to inherit every session tool. Withholding a tool is a stronger constraint than any instruction: an agent without `Write` can't write the payload it forwards.

Give each agent a one-line Identity: the disposition it argues from when a call is close.

This repo deliberately declines some spec fields, and the reasons are recorded here so nobody re-adds them as an oversight. Every skill stays model-invocable instead of using `disable-model-invocation`. Each skill already guards its own side effects, and a user-only skill drops its description from context, which is the only thing that decides whether it is ever reached. `\$ARGUMENTS` covers what these skills take, so `arguments` and its named placeholders go unused. `skills:` preloads a whole `SKILL.md` into an agent at spawn, and no agent here needs a skill's body or reference file. `hooks`, `paths`, `shell`, `isolation`, and `color` add nothing yet.

A reference file is `skills/<name>/<file>.md` with no frontmatter, since it isn't a skill and has no `name` to resolve. Open it with one top-level heading and a lead line naming who reads it and what that reader already has loaded, so the file carries only what that context lacks.

## Triggering

The description is the only part loaded before a skill fires, so it alone decides whether the skill is ever consulted. Write it in two halves: what the skill does, then when to reach for it, in the words a user would type rather than the skill's internal terms. Skills under-fire far more often than they over-fire, so make the trigger wider than feels necessary, and cover prompts that describe the goal without naming the artifact.

A description competes with its siblings. Before calling one done, write three or four prompts a real user would type, including near-misses that belong to a neighbouring skill, and check the description sorts them correctly. This matters most for siblings acting on the same object. If one skill drafts a document and another publishes it, "get this ready to go out" must land on exactly one, which only works if each description claims a verb the other never uses. Fix a prompt that lands on both in the descriptions; don't leave the model to break the tie.

## Token Efficiency

Skills and agents cost tokens on every invocation. Classify each sentence before writing or cutting it.

**Derivable: leave it out.** Anything a current model would produce from the task itself: rationale for a rule it would follow anyway, why an approach is correct, a constraint already stated elsewhere in the file, step-by-step sequencing of an obvious procedure, hedging against mistakes these models don't make.

**Specification: keep word for word.** Anything that can't be derived because it's a fact about this setup or an arbitrary choice: templates and their section order, literal commands and flags, tool and agent names, paths and naming schemes, message and JSON contracts, status vocabularies, thresholds, and every constraint on a destructive or irreversible operation. Never paraphrase a command or reorder a template.

Rationale isn't automatically derivable. Keep a sentence that resolves a case the rules don't list, or that sets the stakes so a reader knows to stop rather than warn. Cut one that only re-explains a rule already given.

When a sentence could be either, keep it: losing a capability costs more than the tokens save. If a constraint could go in either Workflow or Rules, put it where it's more likely to be followed. For a destructive operation, that's an imperative negative in Rules.

## Progressive Disclosure

A skill's body loads in full on every invocation, while a sibling `<name>.md` loads only when something reads it. Splitting a block out saves tokens but costs a `Read` round-trip, and risks the model skipping the read and working from memory, so it only pays off where a real path never reaches the block. Two gates allow a split, and either one is enough. Split wherever one applies, and keep everything else inline.

**Cross-context.** The context that loads the skill isn't the one that uses the block. For example, a skill forbidden from authoring, which delegates that to an agent, pays for every template line and fills in none of them, while the agent reads the whole `SKILL.md` to find them. No skill here has that shape any more, but the gate stands for one that does. A skill pointing at its own sibling uses `CLAUDE_SKILL_DIR` in dollar-and-braces form followed by `/<file>.md`, which Claude Code expands to the installed location. An agent gets no substitution and needs the literal `~/.claude/skills/<name>/<file>.md`. A repo-relative path only works in the repo it was written in. Only Claude Code performs that substitution, so for a skill also installed to another runtime, pair the pointer with a fallback naming that runtime's installed path (`~/.gemini/skills/<name>/<file>.md` for Gemini CLI). That way the other runtime still works instead of hitting the dead stop that "never run this from memory" would leave it in. Name the path explicitly rather than describing it as the skill's own directory: a reader that has to work out the location will search instead of reading.

**Selective bulk.** A block of about 1k tokens or more that a specific, nameable mode never reaches. Measure before splitting: `wc -c` on the section, divided by four. Below that size, the pointer and round-trip cost more than they save. The forge skills are the clean case: a run resolves GitHub or GitLab before doing anything, so the other CLI's command reference is a file that mode never opens. When sibling skills share the same resolve-then-read shape, apply the largest member's measurement to the whole family instead of splitting some and inlining others. `/pr` and `/remote-release` skip well under 1k but keep the split, because one shape learned across four skills is worth more than the few hundred tokens inlining would save.

Length alone opens neither gate. Check whether a section is derivable before extracting it, since cutting beats deferring. Never defer a block that must be reproduced byte-exact, because a skipped read becomes a reconstruction from memory, which a verbatim format can't survive.

`task install` links every `*.md` next to `SKILL.md` and mirrors any `scripts/` or `assets/` directory under it. So a reference file is a flat `<name>.md` sibling, and an executable belongs in `scripts/`. Reach a bundled script through the same variable plus `/scripts/<name>`, and pre-approve that exact path in `allowed-tools`, so repeated deterministic work runs without a prompt instead of being retyped as a command. That substitution in `allowed-tools` needs Claude Code 2.1.129 or newer; on older versions the rule stays literal, never matches, and prompts anyway. Agents have no equivalent (only `AGENT.md` is linked), so neither gate applies to them. An agent carries what it needs in its own file, or reads an installed skill's reference file at `~/.claude/skills/<name>/<file>.md`.

Duplicate text across two files costs nothing at runtime, because skills load one at a time. Never split a file just to remove text another file repeats. The only cost is editing twice, and a shared file that must be read back is worse.

## Writing Style

Write prose paragraphs, not bullets. Bullets fragment context and drop the connecting words that carry intent. Tables and code blocks are the exception, and are the right form for command references and templates.

State hard constraints as violation clauses, in the shape the Clause violation below sets out. Examples are specification: they settle boundaries that prose leaves vague.

Write standing instructions, not one-off steps. A rendered body enters the conversation as one message and stays for the whole session, and Claude Code never re-reads the file on later turns, so a rule phrased as a task to do now stops applying once it's done. `allowed-tools` grants are the exception that proves it: permissions clear on the next message, but instructions don't.

Define the failure paths. A skill that forbids a fallback without saying what to do when its dependency is missing leaves nothing between a forbidden workaround and a dead stop, and the workaround is what happens.

Transcribe commands from the CLI itself, never from memory. If the binary wasn't available and you used a published reference instead, say so in the file, and tell the reader to report the tool's own error instead of substituting a flag that looks close.

## Updating

Read the current file first, and account for every behaviour the change removes. Name each one when reporting the change, so a removal is surfaced now and not discovered later. Cutting derivable prose isn't a removal, as long as every specification item survives.

After an edit meant to shorten a file, diff the rule-bearing sentences (`never`, `must`, `always`, `violation:`) against the original and account for every one that disappeared. Reworded is fine, and moved into a violation clause is fine. Gone is a bug. Never accept a commit message claiming a file was already tightened as evidence; check the file.

## Rules

Always ask scoping questions one at a time, and keep asking until nothing material is unsettled. Then write the file without pausing for approval of the draft.

Aim for 100 lines, counting everything outside the frontmatter, tables, and fenced blocks. Past that, first check whether a section is derivable, then whether a Progressive Disclosure gate applies, before deciding the skill is genuinely large.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Clause violation:** a violation clause that turns on a judgment call but shows only what is forbidden. When the rule is binary (a finding without a number, a `model` key in a SKILL.md), the label and rule settle it and examples can be derived. When it depends on reading an order, a diff, or a request, both halves matter: "running `merge` the order did not name" leaves a legitimate order looking just as refusable until "an order reading `op: merge` with `--squash` is run as written" appears beside it.

**Restatement violation:** a Role section that paraphrases the frontmatter description, which loads with the body anyway, or any constraint stated in both Workflow and Rules.

**Model violation:** a `model` or `effort` key in a SKILL.md, or an AGENT.md that pins `model` without `effort`. The skills spec allows both on a skill, but this repo declines them so that invoking a skill never changes the tier or cost of the session it runs in. That's a house rule, not a platform limit, and the reason has to travel with it or someone will re-add the key because the spec allows it.

**Trigger violation:** a description that stops at what the skill does, or names the artifact without the intent a user would arrive with. "Create a conventional commit from staged changes" alone is a violation, since nothing in it claims the prompt "commit this". The same sentence followed by "Use when the user wants to commit staged changes with a properly formatted commit message" is acceptable.

**Contract violation:** renaming, reordering, or removing a section or field that another file reads back by name, without updating every reader in the same change. `/sdlc-design`'s Task File Format has `## Acceptance Criteria`, which `/sdlc-implement` reads back and a signoff gate compares, so renaming it in one place is a violation. Adding a section no reader indexes, or rewording the prose inside one, is not.

**Substitution violation:** writing a token in the form the runtime replaces, in a sentence that is about the token rather than using it. The rule then renders as the user's own prompt, or as a path to whichever skill is loaded. The two fixes differ. A backslash escapes the arguments token, in prose and inside code spans, so `\$ARGUMENTS` is how to name it literally. `CLAUDE_SKILL_DIR` can't be escaped (the backslash survives and the variable still expands), so name it bare without its sigil and describe the dollar-and-braces form in words. Live forms belong only where the substitution is wanted: the arguments token in the final `## User Input` section, and the braced variable in a path the skill actually reads.

**Disclosure violation:** extracting a block that every path through the skill reads, or pointing a cross-context reader at a repo-relative path instead of the installed one. Splitting out a body template the skill fills in itself is a violation, since the context that composes the body is the one that loaded the template. Splitting out templates that a delegated agent fills in is acceptable, since the context that loads them is forbidden from using them.

## User Input

$ARGUMENTS
