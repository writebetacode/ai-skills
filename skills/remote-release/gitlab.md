# GitLab Commands

Read when the forge resolves to GitLab. Version resolution, the notes draft, the compare link, and the tagging rules are already loaded from `SKILL.md` and are not repeated here.

Release notes always travel as a file path -- let `--notes-file` pass the bytes, and never retype notes text into a command.

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

Three flags on `release-create` differ from their `gh` counterparts. The title is `--name`. **`--no-update` is mandatory** -- without it, creating against a tag that already has a release silently overwrites that release's name and notes instead of failing. And `--ref` *creates* the tag when it does not exist, masking a failed tag push, so omit it: the tag is pushed from this skill first, always.

`glab` takes no target-branch flag on create; `--target` is GitHub's alone. There is no `--generate-notes` equivalent either.

Beware `-F`: it is `--notes-file` on `release create` and `--output` on `release list` and `release view`. The same short flag means different things across sibling commands, so use long forms everywhere and never carry `-F` from one to another.

`glab release delete` prompts without `--yes` and hangs a non-interactive run; `--with-tag` destroys the git tag along with the release.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

**Irreversible violation:** running `release-delete`, or passing `--with-tag`, without the user asking for that in those terms. A deleted release and a deleted tag are not undone by the forge. "Clean this release up" is a violation to bring back as ambiguous; "delete the v1.4.3 release and its tag", confirmed, is acceptable.

When `glab` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop. Never tag or push on the way to a release that cannot then be published.
