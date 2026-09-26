# GitLab Commands

Read this when the forge is GitLab. `SKILL.md` is already loaded. Bodies go in through stdin redirection from the temp file.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `view` | `glab mr view <id> --output json --jq '{iid,title,description,author:.author.username,source:.source_branch,target:.target_branch,sha,state,draft,web_url}'` |
| `diff` | `glab mr diff <id> --raw` |
| `fetch-ref` | `git fetch origin refs/merge-requests/<iid>/head` |
| `threads` | `glab mr view <id> --comments` |
| `comment-list` | `glab mr note list <id> --type general --output json` |
| `thread-list` | `glab mr note list <id> --type diff --output json`, plus `--state unresolved` or `--file <path>` when asked |
| `reply` | `glab mr note create <id> --reply <discussion-id> < <body-file>` |
| `comment` | see anchoring below |
| `review-batch` | no CLI equivalent -- GitLab posts notes one at a time; the findings go up individually |
| `approve` | `glab mr approve <id> --sha <head-sha>` |
| `request-changes` | no CLI equivalent -- `glab mr` has approve and revoke and no changes-requested state; report unsupported |
| `revoke` | `glab mr revoke <id>` |

Anchor each comment according to what the finding recorded:

```sh
glab mr note create <id> --file <path> --line <n> < body.md      # line in the new version
glab mr note create <id> --file <path> --old-line <n> < body.md  # removed line
glab mr note create <id> --file <path> < body.md                 # whole file
glab mr note create <id> < body.md                               # no file anchor
```

## Flags That Bite

The CLI marks `glab mr note` and all its subcommands EXPERIMENTAL. On `note list`, `-F` is `--output` and pairs with `--jq`. `--state` takes `all`, `resolved`, or `unresolved`, and `--type` takes `all`, `general`, `diff`, or `system`. Each discussion's `id` is the full discussion ID, and general and diff discussions both accept a `reply`, so a finding linked to either replies in place. `--reply` accepts a full ID or a prefix of at least 8 characters. A shorter prefix is an error to report, not something to pad. `--line` accepts a number or a range like `10:15`, but always pass a single number here.

The project serves `refs/merge-requests/<iid>/head`, which is the MR's own head commit, so fork MRs fetch through `origin` without adding a remote. That ref name comes from GitLab's published docs, not the CLI. If the fetch fails, report git's error and stop. Never guess a similar ref name.

`glab mr approve` takes no body flag; an approval has no message.

`--line` and `--old-line` each need `--file` and can't be used together. `--file`, `--reply`, and `--unique` are mutually exclusive, so anchored comments can't use `--unique` and nothing prevents a double post. `--resolvable=false` can't be combined with `--file`. Leave it off, since each finding should be a resolvable thread.

Comments land on the latest diff version. If `<head-sha>` isn't the MR's current `.sha`, stop and report instead of posting.

Never resolve or unresolve a discussion. `note resolve` exists, but it never replaces an operation the user actually asked for.

If a command fails, report the CLI's own error word for word instead of retrying with different flags. Never use a flag that isn't in the table.

If `glab` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
