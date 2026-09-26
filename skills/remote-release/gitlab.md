# GitLab Commands

Read when the forge is GitLab; `SKILL.md` is already loaded.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `release-list` | `glab release list --per-page <n> --output json` |
| `release-view` | `glab release view <tag> --output json` |
| `release-create` | `glab release create <tag> --name <title> --notes-file <notes-file> --no-update` |
| `release-upload` | `glab release upload <tag> <files...>` |
| `release-delete` | `glab release delete <tag> --yes`, plus `--with-tag` when asked |

## Flags That Bite

- The title flag is `--name`.
- **`--no-update` is required**: without it, creating against a tag that already has a release silently overwrites its name and notes.
- Never pass `--ref`: it creates a missing tag, hiding a failed tag push.
- No target-branch flag and no `--generate-notes`.
- `-F` is `--notes-file` on `release create` but `--output` on `list` and `view`; use long flags everywhere.
- `release delete` hangs without `--yes`; `--with-tag` deletes the git tag too.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `glab` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.

**Irreversible violation:** running `release-delete` or passing `--with-tag` without the user asking for exactly that; neither is undoable. "Clean this release up" is ambiguous, so ask; "delete the v1.4.3 release and its tag", confirmed, is acceptable.
