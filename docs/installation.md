# Installation and configuration

What `task install` puts on your machine, how to control it, and how to take it back off.

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`, used for the settings merge).

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Skills and agents are symlinked, not copied, so pulling this repo updates them with no reinstall. One set of skill files serves both Claude Code and Gemini CLI; agents install to `~/.claude` only. Every `*.md` in a skill directory is linked, not just `SKILL.md`, so a skill can ship reference files it reads on demand.

`task install` runs `task uninstall` first, so each run reconciles your machine with the current config: newly excluded items are removed, newly included ones come back, and symlinks into this repo whose source no longer exists are cleaned up. Symlinks pointing elsewhere and real files are never touched.

## Choosing what installs

Everything installs by default. Copy `config.example.yml` to `config.yml` (gitignored) and name what you don't want:

```yaml
exclude:
  skills:
    - pr-review
  agents:
    - sdlc-tester

platforms:
  claude: true
  gemini: false      # skip a whole platform

statusline: false    # skip the status line
```

Because it is an exclude list, a skill added to this repo later installs automatically unless you name it. Use block form — inline form (`skills: [pr-review]`) is rejected with an error rather than silently ignored. Run `task config:show` to print the active config, and `task config:check` to validate it alone.

Excluding an agent while keeping the skill that calls it is allowed, and the skill will then stop and tell you the agent is missing rather than falling back to running commands itself.

## What install writes to Claude Code

Two things beyond symlinks: `claude/statusline.sh` is linked into `~/.claude/`, and `claude/settings.json` is merged into `~/.claude/settings.json`. In the merge, permission `allow`/`ask`/`deny` lists are unioned with yours and every other key takes this repo's value — so this repo is the source of truth for the keys it defines, and local edits to those keys are overwritten on the next install. Change them here, not there.

`task uninstall` reverses it: repo-defined keys are deleted, permission entries listed here are subtracted from all three lists, and anything this repo never defined survives untouched. The subtraction spans all three lists deliberately, so an entry that moves between them later cannot leave a stale copy behind.

## Permission policy

Rules evaluate `deny`, then `ask`, then `allow`, so a narrow `ask` rule still prompts even when a broad `allow` rule would match. `defaultMode` is `auto`.

Denied outright — these never run, and the skills are written not to need them:

| Rule | Why |
| --- | --- |
| `git reset --hard`, `git restore`, `git checkout -- <path>`, `git checkout .` | discard uncommitted work with no reflog entry |
| `git clean -f`, `rm -rf` (and `-fr`, `-Rf`) | delete untracked files outright |
| `git push --force`, `git push -f` | rewrite published history |
| `git stash clear`, `git stash drop` | drop stashed work the reflog does not hold |
| `gh release delete`, `glab release delete`, `gh issue delete`, `acli jira workitem delete`, `gh api --method DELETE` | destroy remote records nobody can restore for you |

Prompting every time:

| Rule | Why |
| --- | --- |
| `git branch -d`, `git branch -D` | prompts per branch even though `git branch *` is allowed; backs up `/sdlc-complete`'s own confirmation |
| `git worktree remove --force`, `-f` | plain `remove` already refuses to discard changes, so only the forcing form asks |
| `gh pr review`, `gh pr comment`, `glab mr note create`, `glab mr approve`, `glab mr revoke` | outward-facing and attributed to your account |
| `gh pr close/reopen`, `gh issue comment/edit/close/reopen`, `gh release edit/upload` | change the state of something that already exists |
| `glab mr close/reopen`, `glab issue note/update/close/reopen`, `glab release upload` | the GitLab equivalents |
| `acli jira workitem comment create/edit/transition/assign` | the Jira equivalents |

Allowed: read-only git and forge queries, `git commit` and `git push`, the create paths for PRs, issues, and releases (the skills confirm their content with you before dispatching), Go and pnpm build/test tooling, and `--version`/`--help` probes for the twelve CLIs this repo drives.

One asymmetry to know about: a blanket `Bash(gh api *)` sits in `allow` and covers GitHub's anchored-comment endpoint, so GitHub inline review comments do not prompt where GitLab's do. Narrow or remove that entry if you want them to match.

## Settings keys

Every key `claude/settings.json` defines. Verified against Claude Code 2.1.220; only the two with a version listed have a documented floor.

| Key | Value | Min version | Why |
| --- | --- | --- | --- |
| `permissions` | see above | — | `defaultMode: auto` plus the three lists |
| `effortLevel` | `high` | — | standing default for multi-step work |
| `tui` | `fullscreen` | — | alt-screen renderer, steadier on long runs |
| `askUserQuestionTimeout` | `10m` | 2.1.200 | default is `never`, which blocks an unattended run indefinitely |
| `autoMemoryEnabled` | `false` | — | keeps behaviour dependent only on what is checked in |
| `fileCheckpointingEnabled` | `true` | 2.1.119 | already the default; pinned because it is the main recovery path when `reset --hard` and `restore` are denied |
| `showTurnDuration` | `true` | — | per-turn timing |
| `spinnerTipsEnabled` | `false` | — | stock tips compete with `spinnerVerbs` |
| `spinnerVerbs` | `replace` + list | — | cosmetic |
| `statusLine` | command | — | registers `~/.claude/statusline.sh` |
| `enabledPlugins` | 6 official | — | context7, four LSPs, security-guidance |
| `skipAutoPermissionPrompt` | `true` | — | records that the auto-mode dialog was accepted |
| `skipWorkflowUsageWarning` | `true` | — | same, for the multi-agent usage warning |

`askUserQuestionTimeout` is read from user settings only, which is where `task install` writes — copying it into a project `.claude/settings.json` would do nothing. The two `skip*` keys are acceptance flags rather than documented settings; treat them as implementation detail.

## Status line

```text
ai-skills · ⎇ ABC-1 · Opus5·hi · ctx 33% 65k · 5h 12% ↻1.3h
```

Directory, git branch, model and effort, context window, and the 5-hour rate-limit window with a countdown to reset. Percentages turn yellow at 50% and red at 80%. The line fits 80 columns (or `$COLUMNS`), truncating the branch first and the directory second.

Every value comes from the JSON the harness pipes in — nothing is estimated. Segments whose data is absent disappear rather than showing placeholders, so `rate_limits` is missing until the first API response of a session and on non-subscription auth, and context is briefly missing after `/compact`. Fable 5 is metered in usage credits rather than a percentage window, so no Fable figure can appear here; use `/usage`.

Set `statusline: false` in `config.yml` to skip both the script and the settings key.

## Commands

| Command | Does |
| --- | --- |
| `task install` | uninstall, then link skills and agents and merge settings per `config.yml` |
| `task uninstall` | remove every symlink into this repo and subtract repo-defined settings |
| `task verify` | run every check in order, stopping at the first failure |
| `task doctor` | report installed skills and agents this repo does not manage |
| `task lint:md` | lint every Markdown file here against `.markdownlint.jsonc` |
| `task config:show` | print the active exclusion config |

`task -l` lists these plus the sub-targets they call, such as `task verify:skills-installed`.

`task verify` checks each linked file individually, including reference files, and checks that excluded items are *absent* — so a stale symlink from an earlier install is an error rather than something you discover at runtime.

`task lint:md` sits outside `task verify` because it fetches `markdownlint-cli2` through `npx` on first run, and `verify` must work offline. `task doctor` is advisory: it never fails and never deletes, but it reports live entries that compete with this repo's skills at selection time, plus empty leftover directories that look installed until you open them.
