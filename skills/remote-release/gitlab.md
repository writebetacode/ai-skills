# GitLab Commands

Read this when the forge is GitLab. `SKILL.md` is already loaded.

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

The title flag is `--name`. **`--no-update` is required.** Without it, creating against a tag that already has a release silently overwrites that release's name and notes. Never pass `--ref`: it creates the tag if it's missing, which hides a failed tag push. `glab` has no target-branch flag and no `--generate-notes`.

`-F` is `--notes-file` on `release create` but `--output` on `release list` and `release view`. Use long flag forms everywhere.

`glab release delete` hangs a non-interactive run unless given `--yes`, and `--with-tag` deletes the git tag along with the release.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

**Irreversible violation:** running `release-delete` or passing `--with-tag` when the user didn't ask for exactly that. The forge can't undo a deleted release or tag. "Clean this release up" is too ambiguous to act on, so ask. "Delete the v1.4.3 release and its tag", once confirmed, is acceptable.

If `glab` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
