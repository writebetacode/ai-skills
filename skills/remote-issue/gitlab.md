# GitLab Commands

Read when the tracker is GitLab; `SKILL.md` is already loaded. Descriptions go through `--description-file`, which needs glab 1.115.0 or newer. `glab issue note` has no file flag, so a comment body goes through `"$(cat <path>)"` from the temp file.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `whoami` | `glab api user \| jq -r .username` |
| `issue-view` | `glab issue view <n> --output json --jq '{iid,title,state,web_url}'` |
| `issue-create` | `glab issue create --yes --title <title> --description-file <body-file> --assignee <username>`, plus `--label` and `--epic` when asked |
| `issue-list` | `glab issue list --output json --per-page <n>` |
| `issue-edit` | `glab issue update <n>`, plus `--title`, `--description-file <path>`, `--label`, `--unlabel`, `--assignee`, and `--milestone` as named |
| `issue-comment` | `glab issue note <n> --message "$(cat <body-file>)"` |
| `issue-close` | `glab issue close <n>` |
| `issue-reopen` | `glab issue reopen <n>` |

## Flags That Bite

- `issue create` opens an editor and hangs unless given both `--title` and `--yes`.
- No `@me`: the assignee is the `whoami` username. `glab api` has no `--jq`, so pipe through `jq`; there's no `whoami` subcommand.
- No issue-type flag, so the type always goes in the body.
- No `--parent`: the nearest is `--epic`, taking an epic id on a paid tier. Report a rejection rather than silently dropping the parent.
- On `issue update`, an unprefixed `--assignee` *replaces* the whole set. Prefix `+` to add, `!` or `-` to remove. `--label` adds and `--unlabel` removes; there's no replacing form.
- `-F` on `issue list` is `--output-format` (`details`, `ids`, `urls`), `--output` there is `-O`, and `-F` differs again elsewhere; use long flags everywhere.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `Unknown flag: --description-file` means glab is older than 1.115.0: tell the user to upgrade it and stop.
- `glab` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
