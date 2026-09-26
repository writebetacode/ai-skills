---
name: skill-write
description: Author or revise any file under skills/ or agents/ in this repo -- SKILL.md, AGENT.md, and the reference files and templates beside them -- covering scoping questions, the frontmatter contract, the description rules that decide whether a skill ever fires, and the token-efficiency and progressive-disclosure rules that decide what earns a place in the file. Use when codifying a repetitive task into a skill, a specialized role into an agent, when editing any of those files however small the change looks, when changing a template or format that other files read back, when a skill triggers on the wrong prompts, or when one has grown long enough to be worth splitting.
argument-hint: "[what to write or revise]"
---

# Skill Write

## Workflow

1. Establish which artifact you're writing; frontmatter, path, and questions all differ.
2. Scope it: name, description, workflow steps, rules, and for an agent its tools, model, and effort. Where the conversation already shows the workflow, take the steps, tool names, and corrections from it and confirm them instead of asking cold.
3. Write the file, and update the docs in the same change. `CLAUDE.md` says which of the four documents owns what; a new skill or agent always touches `README.md`'s table plus the document covering its behaviour.
4. Run `task install && task verify && task lint:md` and confirm all three exit 0. `lint:md` needs the network, so `verify` doesn't include it.
5. Read back what the change added and check it against the rules below. Every other check here looks at what was removed, so this is the only pass over the new text.

## File Format

`skills/<name>/SKILL.md` ends with `## User Input` and `\$ARGUMENTS`. One file serves both Claude Code and Gemini CLI. The slash command resolves from the directory name, and `name` only sets the listing label, so keep them equal.

```yaml
---
name: <name>
description: <what it does, then "Use when ...">
argument-hint: "<[thing] the skill expects, omitted when it takes none>"
allowed-tools: "<Bash rules for the skill's read-only commands, omitted when it has none>"
---
```

- **`allowed-tools`** pre-approves; it never restricts, and unlisted tools stay under the session's own permissions. The grant clears on the user's next message, so it suits opening reconnaissance (auth, view, diff, list), not writes a later turn asks for. Grant the narrowest prefix the skill actually runs, down to fixed arguments, never a bare tool name, and nothing the body doesn't name: `Bash(jq:*)` matches a redirect as easily as the pipeline it was added for.
- **`argument-hint`** is always quoted. Unquoted, `[x]` is a YAML sequence and `[x] [y]` doesn't parse, which takes the whole frontmatter down: the skill loses its description and trigger, not just its hint.

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

Agents spawn cold with no session to inherit, so they pin both:

- **`model`** by task: `opus` for design, architecture, and judgment; `sonnet` for routine coding and mechanical dispatch; `haiku` for read-only lookups.
- **`effort`** by reasoning load: `high` for most work, `xhigh` or `max` for subtle correctness.
- **`tools`** scoped narrowly; omit only to inherit every session tool. Withholding a tool beats any instruction: an agent without `Write` can't write the payload it forwards.
- **`memory`** omitted. Its values (`user`, `project`, `local`) all persist across sessions, and every agent here is spawned per task and re-reads its inputs.

Give each agent a one-line Identity: the disposition it argues from when a call is close.

Fields this repo declines, recorded so nobody re-adds them as an oversight:

- `disable-model-invocation`: every skill already guards its own side effects, and a user-only skill drops its description from context, which is the only thing that gets it reached.
- `arguments` and named placeholders: `\$ARGUMENTS` covers what these skills take.
- `skills:` preloads a whole `SKILL.md` into an agent, which suits an agent needing a skill's body rather than a reference file beside it (read at its installed path); no agent here needs either.
- `hooks`, `paths`, `shell`, `isolation`, `color`: nothing gained yet.

A reference file is `skills/<name>/<file>.md` with no frontmatter. Open it with one top-level heading and a lead line naming who reads it and what that reader already has loaded, so it carries only what that context lacks.

## Triggering

The description is the only part loaded before a skill fires, so it alone decides whether the skill is ever consulted. Write what the skill does, then when to reach for it, in the words a user would type. Skills under-fire far more than they over-fire: make the trigger wider than feels necessary, and cover prompts that state the goal without naming the artifact.

Descriptions compete with their siblings. Before calling one done, write three or four realistic prompts, including near-misses belonging to a neighbouring skill, and check they sort correctly. Siblings acting on the same object need distinct verbs: if one skill drafts a document and another publishes it, "get this ready to go out" must land on exactly one. Fix a prompt that lands on both in the descriptions, not by leaving the model to break the tie.

## Token Efficiency

Every invocation pays for every sentence. Classify each one:

- **Derivable, so cut it:** anything a current model produces from the task itself: rationale for a rule the model would follow anyway, why an approach is correct, a constraint already stated elsewhere in the file, sequencing of an obvious procedure, hedging against mistakes current models don't make.
- **Specification, so keep it word for word:** anything that can't be derived because it's a fact about this setup or an arbitrary choice: templates and their section order, literal commands and flags, tool and agent names, paths and naming schemes, message and JSON contracts, status vocabularies, thresholds, and every constraint on a destructive or irreversible operation. Never paraphrase a command or reorder a template.

Rationale isn't automatically derivable. Keep a sentence that resolves a case the rules don't list, or sets the stakes so a reader knows to stop rather than warn; cut one that only re-explains a rule. When unsure, keep it: lost capability costs more than tokens. Put a constraint where it's likeliest to be followed, which for a destructive operation is an imperative negative in Rules.

## Progressive Disclosure

A skill's body loads in full every time; a sibling `<name>.md` loads only when read. A split saves tokens but costs a `Read` round-trip and risks the model skipping it and working from memory. Two gates open a split and either is enough: split wherever one opens, and inline everything else:

- **Cross-context:** the context that loads the skill isn't the one that uses the block, e.g. a skill forbidden from authoring that delegates to an agent, paying for templates it never fills in. No skill here has that shape now; the gate stands for one that does.
- **Selective bulk:** a block of about 1k tokens or more that a nameable mode never reaches. Measure first (`wc -c` on the section, divided by four); below that the pointer and round-trip cost more than they save. The forge skills are the model case: a run resolves GitHub or GitLab first, so the other CLI's reference is never opened. Sibling skills sharing one resolve-then-read shape follow their largest member, which is why `/pr` and `/remote-release` keep the split under 1k.

Length alone opens neither gate. Check whether a section is derivable before extracting it, since cutting beats deferring. Never defer a block that must be reproduced byte-exact: a skipped read becomes a reconstruction from memory.

Paths to a split-out file:

- A skill names its own sibling as `CLAUDE_SKILL_DIR` in dollar-and-braces form plus `/<file>.md`, which Claude Code expands to the installed location.
- Only Claude Code expands it, so pair the pointer with the other runtime's installed path (`~/.gemini/skills/<name>/<file>.md` for Gemini CLI). Otherwise that runtime hits the dead stop "never run this from memory" leaves it in.
- An agent gets no substitution and uses the literal `~/.claude/skills/<name>/<file>.md`.
- Always name the path explicitly. A repo-relative path only resolves in this repo, and a reader left to work out a location searches instead of reading.

`task install` links every `*.md` beside `SKILL.md` and mirrors a `scripts/` or `assets/` directory, so reference files are flat `<name>.md` siblings and executables go in `scripts/`. Reach a bundled script through the same variable plus `/scripts/<name>`, and pre-approve that exact path in `allowed-tools` so repeated deterministic work runs without a prompt; that substitution needs Claude Code 2.1.129 or newer, below which the rule stays literal and prompts anyway. Agents get only `AGENT.md` linked, so neither gate applies: an agent carries what it needs, or reads an installed skill's file at `~/.claude/skills/<name>/<file>.md`.

Duplication across files costs nothing at runtime, because skills load one at a time. Never split a file to remove text another file repeats; editing twice is cheaper than a shared file that must be read back.

## Writing Style

Match the form to the content:

- **Prose** for any rule with a condition, exception, or ordering. The connectives ("unless", "so", "but only") carry the logic, so never break such a rule into bullets of equal weight.
- **Bullets or numbered steps** for flat, independent items: modes, checks, skip lists, files to read, field-by-field notes, a sequence of steps.
- **Tables** for lookups across two or more attributes: commands per operation, fields per tracker, labels per consequence.
- **Code blocks** for templates and literal commands.

State hard constraints as violation clauses, in the shape the Clause violation sets out. Examples are specification: they settle boundaries prose leaves vague.

Write standing instructions, not one-off steps. The body enters the conversation once and Claude Code never re-reads it, so a rule phrased as a task to do now stops applying once done. `allowed-tools` grants are the exception: they clear on the next message while instructions stay.

Define failure paths. A skill that forbids a fallback but never says what to do when its dependency is missing leaves nothing between the forbidden workaround and a dead stop, and the workaround wins.

Transcribe commands from the CLI itself, never from memory. If you had to use a published reference instead, say so in the file, and tell the reader to report the tool's own error rather than try a flag that looks close.

## Updating

Read the current file first. Name every behaviour the change removes when reporting it, so a removal is surfaced rather than discovered later. Cutting derivable prose isn't a removal as long as every specification item survives.

After an edit meant to shorten, diff the rule-bearing sentences (`never`, `must`, `always`, `violation:`) against the original and account for each one that disappeared: reworded or moved into a violation clause is fine; gone is a bug. Never accept a commit message saying a file was already tightened as evidence; check the file.

## Rules

Always ask scoping questions one at a time until nothing material is unsettled, then write the file without pausing for approval of the draft.

Aim for 100 lines, counting everything outside frontmatter, tables, and fenced blocks. Past that, check for derivable sections, then for an open disclosure gate, before deciding the skill is genuinely large.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Clause violation:** a violation clause that turns on judgment but shows only the forbidden side. Where the rule is binary (a finding without a number, a `model` key in a SKILL.md), the label and rule settle it. Where it depends on reading an order, a diff, or a request, show both halves: "running `merge` the order did not name" makes a legitimate order look just as refusable until "an order reading `op: merge` with `--squash` is run as written" sits beside it.

**Restatement violation:** a Role section paraphrasing the frontmatter description, which loads with the body anyway, or any constraint stated in both Workflow and Rules.

**Model violation:** a `model` or `effort` key in a SKILL.md, or an AGENT.md pinning `model` without `effort`. The skills spec allows both on a skill; this repo declines them so invoking a skill never changes the tier or cost of the session it runs in. It's a house rule, not a platform limit, and the reason travels with it so nobody re-adds the key because the spec allows it.

**Trigger violation:** a description that stops at what the skill does, or names the artifact without the intent a user arrives with. "Create a conventional commit from staged changes" alone is a violation, since nothing claims the prompt "commit this"; add "Use when the user wants to commit staged changes with a properly formatted commit message" and it's acceptable.

**Contract violation:** renaming, reordering, or removing a section or field another file reads back by name without updating every reader in the same change. `/sdlc-design`'s Task File Format carries `## Acceptance Criteria`, which `/sdlc-implement` reads and a signoff gate compares, so renaming it in one place is a violation. Adding a section no reader indexes, or rewording prose inside one, is not.

**Substitution violation:** writing a token in its live form in a sentence about the token rather than one using it; it then renders as the user's prompt or a path to whichever skill is loaded. A backslash escapes the arguments token, in prose and code spans alike, so `\$ARGUMENTS` names it literally. `CLAUDE_SKILL_DIR` can't be escaped (the backslash survives and it still expands), so name it bare and describe the dollar-and-braces form in words. Live forms belong only where substitution is wanted: the arguments token in the final `## User Input`, and the braced variable in a path the skill actually reads.

**Disclosure violation:** extracting a block every path through the skill reads, or pointing a cross-context reader at a repo-relative path. Splitting out a body template the skill fills in itself is a violation, since the context that loaded it composes the body; splitting out templates a delegated agent fills in is acceptable, since the loading context is forbidden from using them.

## User Input

$ARGUMENTS
