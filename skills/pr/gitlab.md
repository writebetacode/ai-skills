# GitLab Commands

Read when the forge resolves to GitLab. The body template, the update path, and the title and assignment rules are already loaded from `SKILL.md` and are not repeated here.

Descriptions reach `glab` through `"$(cat <path>)"` -- neither `--description` nor `note create -m` reads a file -- so the composed body still lives in a temp file and is never retyped into a command.

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

`--yes` is mandatory on create -- without it `glab` blocks on an interactive confirmation and the run hangs.

`glab` has no `@me`, so an assignee is a username from `whoami`, and `glab api` is the one command in the table with no `--jq` flag: pipe its JSON through `jq` and read `.username`, rather than reaching for a `whoami` subcommand that does not exist.

`--wip` is a documented alias for `--draft`, not a third state. GitLab keeps the flag in a `Draft:` title prefix, so a title from `view` carries it and `.draft` is what reports the state.

On `mr update`, `--assignee` and `--reviewer` *replace* the existing set unless prefixed -- `+` adds, `!` or `-` removes -- so an unprefixed username silently drops everyone else. `--label` adds and `--unlabel` removes; there is no replacing form.

Beware `-F`: it is `--output` on `mr list` and means something else on sibling commands, so use long forms everywhere. List and view take `--output json` with `--jq`, not a `--json` field list.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `glab` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
