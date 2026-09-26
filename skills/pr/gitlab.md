# GitLab Commands

Read when the forge is GitLab; `SKILL.md` is already loaded. Bodies go through `--description-file`, which needs glab 1.115.0 or newer.

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
| `create` | `glab mr create --yes --title <title> --description-file <body-file> --target-branch <base> --source-branch <head> --assignee <username>`, plus `--draft` when asked |
| `update-description` | `glab mr update <id> --description-file <body-file>` |
| `title` | `glab mr update <id> --title <title>`, plus `--draft` when `view` reported `.draft` true |
| `edit` | `glab mr update <id>`, plus `--label`, `--unlabel`, `--assignee`, `--reviewer`, `--milestone`, and `--target-branch` as named |
| `draft` | `glab mr update <id> --draft` |
| `ready` | `glab mr update <id> --ready` |

## Flags That Bite

- `--yes` is required on create, or `glab` waits for confirmation and hangs.
- No `@me`: the assignee is the `whoami` username. `glab api` has no `--jq`, so pipe through `jq`; there's no `whoami` subcommand.
- `--wip` is an alias for `--draft`, not a third state. Draft is stored as a `Draft:` title prefix, so `view`'s title includes it: read state from `.draft`, and compare a redrafted title with `view`'s minus that prefix.
- `--title` writes the title exactly as given, so on a draft MR a bare `--title` drops the prefix and GitLab marks the MR ready. The `title` row's `--draft` keeps it a draft; it holds the state rather than moving it. This is read from glab 1.119.0's source, since `--help` doesn't say; report the CLI's own error if it behaves otherwise.
- On `mr update`, an unprefixed `--assignee` or `--reviewer` *replaces* the whole set. Prefix `+` to add, `!` or `-` to remove. `--label` adds and `--unlabel` removes; there's no replacing form.
- `-F` is `--output` on `mr list` and something else elsewhere; use long flags everywhere. List and view take `--output json` with `--jq`, not a `--json` field list.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `Unknown flag: --description-file` means glab is older than 1.115.0: tell the user to upgrade it and stop.
- `glab` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
