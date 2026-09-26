# GitLab Commands

Read this when the forge is GitLab. `SKILL.md` is already loaded. `glab` doesn't read description files, so bodies go through `"$(cat <path>)"` from the temp file.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `whoami` | `glab api user \| jq -r .username` |
| `view` | `glab mr view <id> --output json --jq '{iid,title,description,author:.author.username,source:.source_branch,target:.target_branch,sha,state,draft,web_url}'` |
| `description` | `glab mr view <id> --output json --jq .description` |
| `list` | `glab mr list --output json --per-page <n>` |
| `checks` | `glab ci status` -- the pipeline for the current branch, with no MR id of its own |
| `issue-view` | `glab issue view <n> --output json --jq '{iid,title,state,web_url}'` |
| `create` | `glab mr create --yes --title <title> --description "$(cat <body-file>)" --target-branch <base> --source-branch <head> --assignee <username>`, plus `--draft` when asked |
| `update-description` | `glab mr update <id> --description "$(cat <body-file>)"` |
| `title` | `glab mr update <id> --title <title>` |
| `edit` | `glab mr update <id>`, plus `--label`, `--unlabel`, `--assignee`, `--reviewer`, `--milestone`, and `--target-branch` as named |
| `draft` | `glab mr update <id> --draft` |
| `ready` | `glab mr update <id> --ready` |

## Flags That Bite

`--yes` is required on create. Without it, `glab` waits for an interactive confirmation and the run hangs.

`glab` has no `@me`, so the assignee is the username from `whoami`. `glab api` has no `--jq` flag, so pipe it through `jq`. There is no `whoami` subcommand.

`--wip` is an alias for `--draft`, not a third state. GitLab stores draft as a `Draft:` title prefix, so the title from `view` includes it. Read the state from `.draft`.

On `mr update`, an unprefixed `--assignee` or `--reviewer` *replaces* the whole set and drops everyone else. Prefix with `+` to add and `!` or `-` to remove. `--label` adds and `--unlabel` removes; there is no replacing form.

`-F` is `--output` on `mr list` and means something else on other commands, so use long flag forms everywhere. List and view take `--output json` with `--jq`, not a `--json` field list.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

If `glab` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
