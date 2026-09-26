# GitHub Commands

Read this when the forge is GitHub. `SKILL.md` is already loaded.

| Operation | Command |
| --- | --- |
| `auth` | `gh auth status` |
| `repo-id` | `gh repo view --json nameWithOwner --jq .nameWithOwner` |
| `release-list` | `gh release list --limit <n>` |
| `release-view` | `gh release view <tag>` |
| `release-create` | `gh release create <tag> --target <branch> --title <title> --notes-file <notes-file> --verify-tag`, plus `--generate-notes`, `--draft`, or `--prerelease` when asked |
| `release-edit` | `gh release edit <tag>`, plus `--title`, `--notes-file`, `--tag`, `--target`, `--draft`, `--prerelease`, and `--latest` as named |
| `release-upload` | `gh release upload <tag> <files...>`, plus `--clobber` when asked |
| `release-delete` | `gh release delete <tag> --yes`, plus `--cleanup-tag` when asked |

## Flags That Bite

Keep `--verify-tag` on create. It aborts when the tag isn't on the remote, so a failed tag push becomes a refusal instead of a release pointing at nothing. `--generate-notes` appends GitHub's commit list under the supplied body. `gh release delete` prompts unless given `--yes`, and `--cleanup-tag` deletes the git tag along with the release.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

**Irreversible violation:** running `release-delete` or passing `--cleanup-tag` when the user didn't ask for exactly that. The forge can't undo a deleted release or tag, and `--cleanup-tag` removes the tag a published release points to. "Clean this release up" is too ambiguous to act on, so ask. "Delete the v1.4.3 release and its tag", once confirmed, is acceptable.

If `gh` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://cli.github.com> and stop.
