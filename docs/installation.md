# Installation

Requires [Task](https://taskfile.dev) (`brew install go-task`) and [jq](https://jqlang.org) (`brew install jq`) for the settings merge.

```bash
git clone https://github.com/writebetacode/ai-skills
cd ai-skills
task install
```

Symlinks all skills and agents into `~/.claude` and `~/.gemini` so repo updates apply immediately without reinstalling. A single set of skill files serves both platforms; agents are Claude Code only. `task install` runs `task uninstall` first, so it fully reconciles the installed state with your config on every run — newly excluded items are removed, newly re-included ones come back.

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
```

Because it's an exclude list, a skill added to the repo later installs automatically unless you name it. Use block form for the lists — inline form (`skills: [mr]`) is rejected with an error rather than silently ignored.

`task verify` follows the same config: excluded items are checked to be *absent*, so a stale symlink from a previous install is reported as an error. `task install` removes those itself before linking — it deletes any symlink pointing into this repo whose name the repo no longer ships or that `config.yml` now excludes, so excluding a skill takes effect on the next install rather than leaving it live and competing at selection time. Symlinks pointing elsewhere and real files are never touched; those belong to someone else and are only reported, by `task doctor`.

## Git safety rules

The `deny` list blocks irreversible git operations outright — `reset --hard`, `clean -f`, `restore`, and force-push. Branch deletion (`git branch -d/-D`) sits in `ask` instead: rules are evaluated deny, then ask, then allow, so it prompts on every deletion even though `Bash(git branch *)` is allowed, and you approve inline rather than being blocked. That is deliberate — `/prune-branches` and `/sdlc-complete` already require per-branch confirmation, and the permission layer is what enforces it when a prompt-level rule is misread. `git worktree remove` sits in `ask` for the same reason, and `git stash clear`/`git stash drop` in `deny`: both discard work that no commit holds, so neither is recoverable through the reflog the way a bad `checkout` is.

## What install writes

`task install` also symlinks `claude/statusline.sh` into `~/.claude/` — before the merge below, so the `statusLine` command never points at a script that isn't there yet — and merges `claude/settings.json` into `~/.claude/settings.json`: the permission `allow`/`ask`/`deny` lists are unioned, and every other key takes the repo's value — the repo is the source of truth for the settings it defines, so local edits to those keys are overwritten on each install.

`task uninstall` removes every symlink pointing into this repo and subtracts the repo-defined settings back out of `~/.claude/settings.json`: permission entries listed in the repo are removed from `allow`, `ask`, and `deny` alike (including any you happened to add independently — re-add those if needed), repo-defined keys are deleted, and everything the repo never defined survives untouched. The subtraction spans all three lists on purpose: an entry the repo moves between them — `deny` to `ask`, say — would otherwise leave its stale copy behind, and since rules evaluate deny before ask, the move would silently do nothing.

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

## See also

- [Settings keys](settings.md) — every key `claude/settings.json` defines, and why
- [Status line](statusline.md) — what `claude/statusline.sh` renders
- [PR/MR body template](pr-mr-template.md) — the shared template and its fence markers
