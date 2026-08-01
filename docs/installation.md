# Installation and configuration

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`) for the settings merge.

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Symlinks all skills and agents into `~/.claude` and `~/.gemini` so repo updates apply immediately without reinstalling. A single set of skill files serves both platforms; agents install to `~/.claude` only.

Every `*.md` in a skill or agent directory is linked, not just `SKILL.md`, so a skill can ship reference files it reads on demand — `skills/sdlc-design/templates.md` and `skills/pr-review/posting.md` are the two that do. `task verify` checks each of them individually, so a reference file that failed to link is an error rather than a gap the skill only discovers at runtime, and `task install` removes the link when the source file is renamed or deleted. `task install` runs `task uninstall` first, so it fully reconciles the installed state with your config on every run — newly excluded items are removed, newly re-included ones come back.

## Choosing what gets installed

Everything installs by default. To opt out of specific skills or agents, copy `config.example.yml` to `config.yml` (gitignored) and list the directory names you don't want:

```yaml
exclude:
  skills:
    - pr-review
    - remote-issue
  agents:
    - sdlc-tester

platforms:
  claude: true
  gemini: false      # skip a whole platform

statusline: false    # skip the status line
```

Because it's an exclude list, a skill added to the repo later installs automatically unless you name it. Use block form for the lists — inline form (`skills: [pr-review]`) is rejected with an error rather than silently ignored.

`statusline: false` skips the status line specifically: `statusline.sh` is not linked and the `statusLine` key is dropped from the settings merge, so your existing `~/.claude/settings.json` keeps whatever it already had. The two go together deliberately — linking without the key would leave a script nothing invokes, and merging the key without the script would point `statusLine` at a path that does not exist. `task verify` then checks the symlink is *absent*, the same way it treats an excluded skill.

`task verify` follows the same config: excluded items are checked to be *absent*, so a stale symlink from a previous install is reported as an error. `task install` removes those itself before linking — it deletes any symlink pointing into this repo whose name the repo no longer ships or that `config.yml` now excludes, so excluding a skill takes effect on the next install rather than leaving it live and competing at selection time. Symlinks pointing elsewhere and real files are never touched; those belong to someone else and are only reported, by `task doctor`.

## What install writes

`task install` symlinks `claude/statusline.sh` into `~/.claude/` — before the settings merge, so the `statusLine` command never points at a script that isn't there yet — and merges `claude/settings.json` into `~/.claude/settings.json`: the permission `allow`/`ask`/`deny` lists are unioned, and every other key takes the repo's value. The repo is the source of truth for the settings it defines, so local edits to those keys are overwritten on each install.

`task uninstall` removes every symlink pointing into this repo and subtracts the repo-defined settings back out of `~/.claude/settings.json`: permission entries listed in the repo are removed from `allow`, `ask`, and `deny` alike (including any you happened to add independently — re-add those if needed), repo-defined keys are deleted, and everything the repo never defined survives untouched. The subtraction spans all three lists on purpose: an entry the repo moves between them — `deny` to `ask`, say — would otherwise leave its stale copy behind, and since rules evaluate deny before ask, the move would silently do nothing.

## Git and forge safety rules

Posting to a forge gets the same treatment as deleting a branch. Publishing a review comment, approving, or revoking approval is outward-facing and attributed to your account, so `glab mr note create`, `glab mr approve`, `glab mr revoke`, `gh pr review`, and `gh pr comment` sit in `ask` and prompt every time, backstopping the explicit-request rule `/pr-review` already carries. Read-only forge commands and the create paths — issues, PRs, releases — sit in `allow`, matching how the skills treat them: those confirm their content with you before dispatching. Flipping a PR or MR between draft and ready is in `allow` too, under `Bash(gh pr ready *)` and the existing `Bash(glab mr update *)`: it publishes no text and is reversed by the opposite operation, and an agent blocked on a prompt mid-dispatch is worse than either. One asymmetry worth knowing: a pre-existing blanket `Bash(gh api *)` in `allow` covers GitHub's anchored-comment endpoint, so GitHub inline comments do not prompt where GitLab's do. Narrow or remove that entry if you want them to behave alike.

The `deny` list blocks irreversible git operations outright — `reset --hard`, `clean -f`, `restore`, and force-push. Branch deletion (`git branch -d/-D`) sits in `ask` instead: rules are evaluated deny, then ask, then allow, so it prompts on every deletion even though `Bash(git branch *)` is allowed, and you approve inline rather than being blocked. That is deliberate — `/sdlc-complete` already requires per-branch confirmation, and the permission layer is what enforces it when a prompt-level rule is misread. Worktrees are split finer, because the plain command already protects itself: `git worktree remove` refuses to delete a worktree holding uncommitted or untracked changes, so it sits in `allow` alongside `add`, `list`, `prune`, and `move`, while `git worktree remove --force` and its `-f` short form sit in `ask` — forcing is the part that discards work. That split is pattern-based, so it holds for `remove --force <path>` and not for `remove <path> --force`; git accepts both orderings, and only the first matches. `git stash clear`/`git stash drop` sit in `deny`: both discard work that no commit holds, so neither is recoverable through the reflog the way a bad `checkout` is.

## Version and help probes

`allow` ends with a block covering `--version`, `--help`, `-h`, and the `version`/`help` subcommands of the twelve CLIs this repo actually drives: `git`, the three forge and tracker CLIs the agents shell out to (`gh`, `glab`, `acli`), the Go toolchain (`go`, `gofmt`, `golangci-lint`), and the Node one (`node`, `npm`, `npx`, `pnpm`, `markdownlint-cli2`). `which` and `command -v` come with them. These read nothing and change nothing, and the answer to "is `glab` installed here" is exactly the sort of prompt that trains you to stop reading them. The entries pair with the skills that stop the run when a CLI is absent: `/pr`, `/pr-review`, `/remote-issue`, and `/remote-release` all report a missing binary rather than working around it, and each agent reports `command not found` as its own failure, so probing has to be cheap for that path to stay quick.

`task` and `jq` are absent because `Bash(task *)` and `Bash(jq *)` already blanket them. Keep the block to tools the repo drives rather than every CLI a machine might have — an allowlist nobody can read is one nobody audits, and each unused entry is a rule that has to be checked against `deny` and `ask` on every match.

Each entry is written out in full — `Bash(go --version)` — rather than a single leading-wildcard rule like `Bash(* --version)`. The [settings reference](https://code.claude.com/docs/en/settings) documents the `Bash(...)` form only through examples (`Bash(npm run lint)` exact, `Bash(npm run test *)` prefixed) and never states whether a pattern may begin with a wildcard, so the block enumerates instead of depending on undocumented behaviour. A flag a given tool does not have is inert — the rule simply never matches.

Two flags are deliberately absent: `-v` means verbose at least as often as it means version, and `-V` is inconsistent enough across tools to be worth the occasional prompt. So is `npm version`, which bumps `package.json` and tags a release rather than reporting anything; `npm --version` is the probe. Every entry except `--help *` and the `help *` subcommands is written without a trailing wildcard, following the reference's exact form, so each one covers the bare probe and nothing longer.

## Settings keys

Every key `claude/settings.json` defines. Because the merge makes the repo the source of truth for the keys it names, these are imposed on each install rather than suggested — change them here, not in `~/.claude/settings.json`, or the next install reverts them.

| Key | Value | Min version | Why |
| --- | --- | --- | --- |
| `permissions` | see above | — | `defaultMode: auto`, plus the `allow`/`ask`/`deny` lists described above. |
| `effortLevel` | `high` | — | Standing default for multi-step work. `xhigh` exists but is better invoked per-task than left on. |
| `tui` | `fullscreen` | — | Flicker-free alt-screen renderer with virtualised scrollback; steadier on long runs than the classic main-screen one. |
| `askUserQuestionTimeout` | `10m` | 2.1.200 | Default is `never`, so an unanswered question blocks indefinitely. Ten minutes lets an unattended `/sdlc-implement` run continue with whatever was already selected. |
| `autoMemoryEnabled` | `false` | — | Default is `true`. Off here so session state stays out of the auto-memory directory and behaviour depends only on what is checked in. |
| `fileCheckpointingEnabled` | `true` | 2.1.119 | Already the default — set explicitly because it is the main recovery path in this repo, where `reset --hard`, `restore`, and `checkout --` are all denied. Pinning it means a global opt-out elsewhere cannot silently remove that safety net. |
| `showTurnDuration` | `true` | — | Per-turn timing, alongside the status line's context and rate-limit readouts. |
| `spinnerTipsEnabled` | `false` | — | The stock tips compete with the custom `spinnerVerbs`. |
| `spinnerVerbs` | `replace` + list | — | Cosmetic. `replace` rather than `append` so only these appear. |
| `statusLine` | command | — | Registers `~/.claude/statusline.sh`; see below. |
| `enabledPlugins` | 6 official | — | context7 for library docs, four LSPs, and security-guidance. |
| `skipAutoPermissionPrompt` | `true` | — | Records that the auto-mode dialog was accepted, so `defaultMode: auto` does not re-prompt on a fresh machine. |
| `skipWorkflowUsageWarning` | `true` | — | Same idea for the multi-agent workflow usage warning. |

Only `askUserQuestionTimeout` and `fileCheckpointingEnabled` carry a documented version floor; the rest are long-standing and unannotated in the [settings reference](https://code.claude.com/docs/en/settings). Everything here is verified against Claude Code 2.1.220. Two caveats: `askUserQuestionTimeout` is read from user settings only — which is where `task install` writes, so it applies, but copying it into a project `.claude/settings.json` would silently do nothing — and `skipAutoPermissionPrompt` and `skipWorkflowUsageWarning` are acceptance flags rather than documented settings, so treat them as implementation detail.

## Status line

`claude/statusline.sh` is symlinked to `~/.claude/statusline.sh` and registered via the `statusLine` key, so edits in the repo take effect immediately with no reinstall. Set `statusline: false` in `config.yml` to skip it entirely. It renders:

```text
ai-skills · ⎇ ABC-1 · Opus5·hi · ctx 33% 65k · 5h 12% ↻1.3h
```

Directory and git worktree, model and reasoning effort (`lo`/`md`/`hi`/`xh`), context window (percentage plus absolute tokens), and the 5-hour rate-limit window with a countdown to its reset. Percentages turn yellow at 50% and red at 80%, rounded so the colour never disagrees with the number beside it.

The line is built to fit 80 columns — or `$COLUMNS`, if the terminal exports it. Should it overrun, the branch is truncated with an ellipsis, then dropped entirely if fewer than three characters would survive, and only then is the directory trimmed, to a floor of eight characters. The fixed-width segments are never sacrificed. Model and effort stay abbreviated (`Opus5·hi`), which keeps roughly nine columns in reserve for long branch names.

Reset countdowns always round *up*, to one decimal where the unit warrants it — `1.1h`, `1.1d` — because under-reporting time remaining is the costly direction. A trailing `.0` is dropped, so exact values stay compact (`2h`, `7d`), and the unit only changes at a full 1.0, so 23 hours reads `23h` rather than `0.9d`. Anything under a minute renders `<1m` instead of rounding up to `1m`, which would imply headroom that isn't there.

Every value comes from the JSON the harness pipes in on stdin — nothing is scraped or estimated. Segments whose fields are absent drop out silently rather than rendering placeholders: `rate_limits` is missing until the first API response of a session and for non-subscription auth, and `context_window.current_usage` is null immediately after `/compact`. `refreshInterval: 60` is set because the reset countdowns are time-based and the harness otherwise re-renders only on events, which would leave them stale while idle.

One limit worth knowing, a property of the data rather than the script: Fable 5 is metered against dollar-denominated usage credits rather than a percentage window, so no Fable figure can appear here. Use `/usage` and `/usage-credits` for that.

## Verification and teardown

```bash
task uninstall                 # remove symlinks and subtract repo-defined settings
task verify                    # run every check below, in order
task verify:skills-installed   # check all symlinks
task doctor                    # report installed skills/agents this repo does not manage
task lint:md                   # lint every Markdown file in the repo
```

`task verify` runs the checks sequentially and stops at the first failure, so fix an early failure to see the later checks run.

`task lint:md` runs `markdownlint-cli2` over every `*.md` here against `.markdownlint.jsonc`, and needs Node.js — it fetches the linter through `npx` on first run. That network dependency is why it sits outside `task verify`, which must keep working offline; run it yourself after editing prose. The config takes markdownlint's defaults with one exception: `MD013` (line length) is off, because prose here is one line per paragraph so that editing a sentence produces a one-line diff instead of reflowing the paragraph around it.

`task doctor` runs last and is advisory — it never fails the build and never deletes anything. It reports two things `verify` cannot: `UNMANAGED` entries (a real file, or a symlink pointing outside this repo) that are live and compete with repo skills at selection time, and `EMPTY` leftover directories from an earlier layout of this repo, which are inert but look like installed skills until you look inside. `verify:skills-installed` only checks that expected entries exist, so neither shows up there. Remove anything you no longer want by hand.
