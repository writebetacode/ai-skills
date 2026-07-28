# Installation and configuration

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`) for the settings merge.

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Symlinks all skills and agents into `~/.claude` and `~/.gemini` so repo updates apply immediately without reinstalling. A single set of skill files serves both platforms; agents install to `~/.claude` only. `task install` runs `task uninstall` first, so it fully reconciles the installed state with your config on every run — newly excluded items are removed, newly re-included ones come back.

## Choosing what gets installed

Everything installs by default. To opt out of specific skills or agents, copy `config.example.yml` to `config.yml` (gitignored) and list the directory names you don't want:

```yaml
exclude:
  skills:
    - mr
    - gh-issue
  agents:
    - sdlc-tester

platforms:
  claude: true
  gemini: false      # skip a whole platform

statusline: false    # skip the status line
```

Because it's an exclude list, a skill added to the repo later installs automatically unless you name it. Use block form for the lists — inline form (`skills: [mr]`) is rejected with an error rather than silently ignored.

`statusline: false` skips the status line specifically: `statusline.sh` is not linked and the `statusLine` key is dropped from the settings merge, so your existing `~/.claude/settings.json` keeps whatever it already had. The two go together deliberately — linking without the key would leave a script nothing invokes, and merging the key without the script would point `statusLine` at a path that does not exist. `task verify` then checks the symlink is *absent*, the same way it treats an excluded skill.

`task verify` follows the same config: excluded items are checked to be *absent*, so a stale symlink from a previous install is reported as an error. `task install` removes those itself before linking — it deletes any symlink pointing into this repo whose name the repo no longer ships or that `config.yml` now excludes, so excluding a skill takes effect on the next install rather than leaving it live and competing at selection time. Symlinks pointing elsewhere and real files are never touched; those belong to someone else and are only reported, by `task doctor`.

## What install writes

`task install` symlinks `claude/statusline.sh` into `~/.claude/` — before the settings merge, so the `statusLine` command never points at a script that isn't there yet — and merges `claude/settings.json` into `~/.claude/settings.json`: the permission `allow`/`ask`/`deny` lists are unioned, and every other key takes the repo's value. The repo is the source of truth for the settings it defines, so local edits to those keys are overwritten on each install.

`task uninstall` removes every symlink pointing into this repo and subtracts the repo-defined settings back out of `~/.claude/settings.json`: permission entries listed in the repo are removed from `allow`, `ask`, and `deny` alike (including any you happened to add independently — re-add those if needed), repo-defined keys are deleted, and everything the repo never defined survives untouched. The subtraction spans all three lists on purpose: an entry the repo moves between them — `deny` to `ask`, say — would otherwise leave its stale copy behind, and since rules evaluate deny before ask, the move would silently do nothing.

## Git safety rules

The `deny` list blocks irreversible git operations outright — `reset --hard`, `clean -f`, `restore`, and force-push. Branch deletion (`git branch -d/-D`) sits in `ask` instead: rules are evaluated deny, then ask, then allow, so it prompts on every deletion even though `Bash(git branch *)` is allowed, and you approve inline rather than being blocked. That is deliberate — `/prune-branches` and `/sdlc-complete` already require per-branch confirmation, and the permission layer is what enforces it when a prompt-level rule is misread. `git worktree remove` sits in `ask` for the same reason, and `git stash clear`/`git stash drop` in `deny`: both discard work that no commit holds, so neither is recoverable through the reflog the way a bad `checkout` is.

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

```
ai-skills · ⎇ ABC-1 · Opus5·hi · ctx 33% 65k · 5h 12% ↻1.3h
```

Directory and git worktree, model and reasoning effort (`lo`/`md`/`hi`/`xh`), context window (percentage plus absolute tokens), and the 5-hour rate-limit window with a countdown to its reset. Percentages turn yellow at 50% and red at 80%, rounded so the colour never disagrees with the number beside it.

The line is built to fit 80 columns — or `$COLUMNS`, if the terminal exports it. Should it overrun, the branch is truncated with an ellipsis, then dropped entirely if fewer than three characters would survive, and only then is the directory trimmed, to a floor of eight characters. The fixed-width segments are never sacrificed. Model and effort stay abbreviated (`Opus5·hi`), which keeps roughly nine columns in reserve for long branch names.

Reset countdowns always round *up*, to one decimal where the unit warrants it — `1.1h`, `1.1d` — because under-reporting time remaining is the costly direction. A trailing `.0` is dropped, so exact values stay compact (`2h`, `7d`), and the unit only changes at a full 1.0, so 23 hours reads `23h` rather than `0.9d`. Anything under a minute renders `<1m` instead of rounding up to `1m`, which would imply headroom that isn't there.

Every value comes from the JSON the harness pipes in on stdin — nothing is scraped or estimated. Segments whose fields are absent drop out silently rather than rendering placeholders: `rate_limits` is missing until the first API response of a session and for non-subscription auth, and `context_window.current_usage` is null immediately after `/compact`. `refreshInterval: 60` is set because the reset countdowns are time-based and the harness otherwise re-renders only on events, which would leave them stale while idle.

One limit worth knowing, a property of the data rather than the script: Fable 5 is metered against dollar-denominated usage credits rather than a percentage window, so no Fable figure can appear here. Use `/usage` and `/usage-credits` for that.

## PR/MR body template

`/pr` and `/mr` write the same structured description, so review artifacts read the same on both forges. The template is duplicated verbatim between the two skills (skills load standalone — no include mechanism), marked with `<!-- pr-body:v1 -->` and checked by `task verify:pr-body`. The marker sits below the section heading, so `## PR Body Template` and `## MR Body Template` may differ while everything from the intro line through the closing fence stays byte-identical. Edit both files and bump the marker together.

The template body is wrapped in `<!-- mr-body:start -->` / `<!-- mr-body:end -->` markers that both skills write into the description. These delimit the region the skills own: on update they rewrite only what sits between the markers, and everything outside is preserved byte-for-byte in its original position — reviewer-bot summaries such as Cursor Bugbot's, other tooling's generated blocks, and hand-written additions all survive. The rule is positional, not name-based: neither skill knows what any particular bot is called, and content is preserved because of where it sits, not because it was recognized. An HTML comment under the opener states that the region is autogenerated, so the warning reaches whoever is in the edit box.

Descriptions predating the markers are migrated in place on the next update: the skill locates the contiguous run of template sections, replaces that run with the fenced body, and leaves surrounding content where it sits. An unpaired opener is treated as unfenced rather than as a boundary, so a hand-deleted closer cannot swallow the rest of the body.

## Verification and teardown

```bash
task uninstall                 # remove symlinks and subtract repo-defined settings
task verify                    # run every check below, in order
task verify:skills-installed   # check all symlinks
task verify:pr-body            # check the shared PR/MR body template has not drifted
task doctor                    # report installed skills/agents this repo does not manage
```

`task verify` runs the checks sequentially and stops at the first failure, so fix an early failure to see the later checks run.

`task doctor` runs last and is advisory — it never fails the build and never deletes anything. It reports two things `verify` cannot: `UNMANAGED` entries (a real file, or a symlink pointing outside this repo) that are live and compete with repo skills at selection time, and `EMPTY` leftover directories from an earlier layout of this repo, which are inert but look like installed skills until you look inside. `verify:skills-installed` only checks that expected entries exist, so neither shows up there. Remove anything you no longer want by hand.
