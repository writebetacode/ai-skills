# GitLab Commands

Read this when the tracker is GitLab. `SKILL.md` is already loaded. `glab` doesn't read description files, so bodies go through `"$(cat <path>)"` from the temp file.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `whoami` | `glab api user \| jq -r .username` |
| `issue-view` | `glab issue view <n> --output json --jq '{iid,title,state,web_url}'` |
| `issue-create` | `glab issue create --yes --title <title> --description "$(cat <body-file>)" --assignee <username>`, plus `--label` and `--epic` when asked |
| `issue-list` | `glab issue list --output json --per-page <n>` |
| `issue-edit` | `glab issue update <n>`, plus `--title`, `--description "$(cat <path>)"`, `--label`, `--unlabel`, `--assignee`, and `--milestone` as named |
| `issue-comment` | `glab issue note <n> --message "$(cat <body-file>)"` |
| `issue-close` | `glab issue close <n>` |
| `issue-reopen` | `glab issue reopen <n>` |

## Flags That Bite

`issue create` opens an editor, which hangs the run, unless you pass both `--title` and `--yes`.

`glab` has no `@me`, so the assignee is the username from `whoami`. `glab api` has no `--jq` flag, so pipe it through `jq`. There is no `whoami` subcommand.

There is no issue-type flag, so the type always goes in the body. There is no `--parent` either. The nearest equivalent is `--epic`, which takes an epic id and needs a paid tier. If it's rejected, report that instead of quietly dropping the parent.

On `issue update`, an unprefixed `--assignee` *replaces* the whole set and drops everyone else. Prefix with `+` to add and `!` or `-` to remove. `--label` adds and `--unlabel` removes; there is no replacing form.

`-F` on `issue list` is `--output-format` (`details`, `ids`, `urls`), while `--output` there is `-O`, and `-F` means something else again on other commands. Use long flag forms everywhere.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

If `glab` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
