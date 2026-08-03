# GitLab Commands

Read when the tracker is GitLab. The body template, the field mapping, and the title rules are already loaded from `SKILL.md` and are not repeated here.

`glab` reads no description file, so the composed body still lives in a temp file and reaches the CLI through `"$(cat <path>)"` rather than being retyped into a command.

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

`issue create` opens an editor unless both `--title` and `--yes` are passed, which hangs a non-interactive run.

`glab` has no `@me`, so an assignee is a username from `whoami`, and `glab api` is the one command in the table with no `--jq` flag: pipe its JSON through `jq` and read `.username`, rather than reaching for a `whoami` subcommand that does not exist.

GitLab has no issue-type flag at all, so the body always carries the type there. There is no `--parent` either: GitLab's analogue is `--epic`, taking an epic id, and it is a paid-tier feature -- report a rejection rather than dropping the parent silently.

`glab issue note` takes only `--message`, with no file flag, so the body goes through `"$(cat <path>)"` like a description. On `issue update`, `--assignee` *replaces* the existing set unless prefixed -- `+` adds, `!` or `-` removes -- so an unprefixed username silently drops everyone else. `--label` adds and `--unlabel` removes; there is no replacing form.

Beware `-F`: on `issue list` it is `--output-format` (`details`, `ids`, `urls`) while `--output` there is `-O`, and it means different things again on sibling commands. Use long forms everywhere and never carry `-F` from one command to another.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `glab` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
