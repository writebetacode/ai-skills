# GitHub Commands

Read when the forge is GitHub; `SKILL.md` is already loaded.

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

- Keep `--verify-tag` on create: it turns a failed tag push into a refusal instead of a release pointing at nothing.
- `--generate-notes` appends GitHub's commit list under the supplied body.
- `release delete` prompts without `--yes`; `--cleanup-tag` deletes the git tag too.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `gh` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://cli.github.com> and stop.

**Irreversible violation:** running `release-delete` or passing `--cleanup-tag` without the user asking for exactly that. Neither is undoable, and `--cleanup-tag` removes the tag a published release points to. "Clean this release up" is ambiguous, so ask; "delete the v1.4.3 release and its tag", confirmed, is acceptable.
