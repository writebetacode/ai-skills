# Settings keys

Every key `claude/settings.json` defines, and why. Because the merge makes the repo the source of truth for the keys it names, these are imposed on each install rather than suggested — change them here, not in `~/.claude/settings.json`, or the next install reverts them.

| Key | Value | Min version | Why |
| --- | --- | --- | --- |
| `permissions` | see below | — | `defaultMode: auto`, plus the `allow`/`ask`/`deny` lists described in [Installation](installation.md#git-safety-rules). |
| `effortLevel` | `high` | — | Standing default for multi-step work. `xhigh` exists but is better invoked per-task than left on. |
| `tui` | `fullscreen` | — | Flicker-free alt-screen renderer with virtualised scrollback; steadier on long runs than the classic main-screen one. |
| `askUserQuestionTimeout` | `10m` | 2.1.200 | Default is `never`, so an unanswered question blocks indefinitely. Ten minutes lets an unattended `/sdlc-implement` run continue with whatever was already selected. |
| `autoMemoryEnabled` | `false` | — | Default is `true`. Off here so session state stays out of the auto-memory directory and behaviour depends only on what is checked in. |
| `fileCheckpointingEnabled` | `true` | 2.1.119 | Already the default — set explicitly because it is the main recovery path in this repo, where `reset --hard`, `restore`, and `checkout --` are all denied. Pinning it means a global opt-out elsewhere cannot silently remove that safety net. |
| `showTurnDuration` | `true` | — | Per-turn timing, alongside the status line's context and rate-limit readouts. |
| `spinnerTipsEnabled` | `false` | — | The stock tips compete with the custom `spinnerVerbs` below. |
| `spinnerVerbs` | `replace` + list | — | Cosmetic. `replace` rather than `append` so only these appear. |
| `statusLine` | command | — | Registers `~/.claude/statusline.sh`; see [Status line](statusline.md). |
| `enabledPlugins` | 6 official | — | context7 for library docs, four LSPs, and security-guidance. |
| `skipAutoPermissionPrompt` | `true` | — | Records that the auto-mode dialog was accepted, so `defaultMode: auto` does not re-prompt on a fresh machine. |
| `skipWorkflowUsageWarning` | `true` | — | Same idea for the multi-agent workflow usage warning. |

## Version floors and caveats

Only `askUserQuestionTimeout` and `fileCheckpointingEnabled` carry a documented version floor; the rest are long-standing and unannotated in the [settings reference](https://code.claude.com/docs/en/settings). Everything here is verified against Claude Code 2.1.220.

Two caveats worth knowing:

- `askUserQuestionTimeout` is read from user settings only — which is where `task install` writes, so it applies, but copying it into a project `.claude/settings.json` would silently do nothing.
- `skipAutoPermissionPrompt` and `skipWorkflowUsageWarning` are acceptance flags rather than documented settings, so treat them as implementation detail.
