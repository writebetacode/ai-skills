# GitHub Commands

Read when the forge resolves to GitHub. Version resolution, the notes draft, the compare link, and the tagging rules are already loaded from `SKILL.md` and are not repeated here.

Release notes always travel as a file path -- let `--notes-file` pass the bytes, and never retype notes text into a command.

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

Keep `--verify-tag` on create: it aborts when the tag is not on the remote, turning a silently failed tag push into a refusal rather than a release pointing at nothing. `--generate-notes` appends GitHub's own commit list beneath the supplied body, so pass it only when the drafted body is meant to carry it. `--target` is GitHub's alone; GitLab takes no equivalent.

`gh release delete` prompts without `--yes`, and `--cleanup-tag` takes the git tag with the release.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

**Irreversible violation:** running `release-delete`, or passing `--cleanup-tag`, without the user asking for that in those terms. A deleted release and a deleted tag are not undone by the forge, and `--cleanup-tag` destroys the tag a published release pointed at. "Clean this release up" is a violation to bring back as ambiguous; "delete the v1.4.3 release and its tag", confirmed, is acceptable.

When `gh` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://cli.github.com> and stop. Never tag or push on the way to a release that cannot then be published.
