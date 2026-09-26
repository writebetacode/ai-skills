# GitLab Commands

Read when the forge is GitLab; `SKILL.md` is already loaded. Bodies go in by stdin redirection from the temp file.

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

Anchor by what the finding recorded:

```sh
glab mr note create <id> --file <path> --line <n> < body.md      # line in the new version
glab mr note create <id> --file <path> --old-line <n> < body.md  # removed line
glab mr note create <id> --file <path> < body.md                 # whole file
glab mr note create <id> < body.md                               # no file anchor
```

## Flags That Bite

- `glab mr note` and all its subcommands are marked EXPERIMENTAL.
- On `note list`, `-F` is `--output` and pairs with `--jq`. `--state` takes `all`, `resolved`, or `unresolved`; `--type` takes `all`, `general`, `diff`, or `system`.
- Each discussion's `id` is the full discussion ID, and general and diff discussions both take a `reply`, so a finding linked to either replies in place.
- `--reply` takes a full ID or a prefix of at least 8 characters; a shorter one is an error to report, not pad.
- `--line` accepts a number or a `10:15` range; always pass a single number here.
- `--line` and `--old-line` each need `--file` and can't be combined.
- `--file`, `--reply`, and `--unique` are mutually exclusive, so anchored comments can't use `--unique` and nothing prevents a double post.
- `--resolvable=false` can't combine with `--file`; leave it off, since each finding should be a resolvable thread.
- `glab mr approve` takes no body flag; approvals have no message.
- The project serves `refs/merge-requests/<iid>/head`, the MR's own head, so fork MRs fetch through `origin` with no extra remote. That ref name comes from GitLab's docs, not the CLI: if the fetch fails, report git's error and stop; never guess a neighbouring ref.
- Comments land on the latest diff version: if `<head-sha>` isn't the MR's current `.sha`, stop and report instead of posting.
- Never resolve or unresolve a discussion; `note resolve` never substitutes for an operation actually asked for.
- On failure, report the CLI's own error verbatim rather than retrying with other flags, and never use a flag missing from the table.
- `glab` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
