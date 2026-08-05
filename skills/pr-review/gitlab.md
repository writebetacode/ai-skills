# GitLab Commands

Read when the forge resolves to GitLab. The suggestion fence, the verdict mapping, finding numbering, and the Voice rules are already loaded from `SKILL.md` and are not repeated here.

Every comment body travels as a file path -- the summary line, the anchor, and any suggestion block have to arrive byte-exact, so write each body to a temp file outside the repo and let stdin redirection pass the bytes.

| Operation | Command |
| --- | --- |
| `auth` | `glab auth status` |
| `repo-id` | `glab repo view --output json --jq .path_with_namespace` |
| `view` | `glab mr view <id> --output json --jq '{iid,title,description,author:.author.username,source:.source_branch,target:.target_branch,sha,state,draft,web_url}'` |
| `diff` | `glab mr diff <id> --raw` |
| `fetch-ref` | `git fetch origin refs/merge-requests/<iid>/head` |
| `threads` | `glab mr view <id> --comments` |
| `thread-list` | `glab mr note list <id> --type diff --output json`, plus `--state unresolved` or `--file <path>` when asked |
| `reply` | `glab mr note create <id> --reply <discussion-id> < <body-file>` |
| `comment` | see anchoring below |
| `review-batch` | no CLI equivalent -- GitLab posts notes one at a time; the findings go up individually |
| `approve` | `glab mr approve <id> --sha <head-sha>` |
| `request-changes` | no CLI equivalent -- `glab mr` has approve and revoke and no changes-requested state; report unsupported |
| `revoke` | `glab mr revoke <id>` |

Comment anchoring, by what the finding recorded:

```sh
glab mr note create <id> --file <path> --line <n> < body.md      # line in the new version
glab mr note create <id> --file <path> --line <a>:<b> < body.md  # range in the new version
glab mr note create <id> --file <path> --old-line <n> < body.md  # removed line
glab mr note create <id> --file <path> < body.md                 # whole file
glab mr note create <id> < body.md                               # no file anchor
```

## Flags That Bite

`glab mr note` and every one of its subcommands are marked EXPERIMENTAL by the CLI, so report the tool's own error verbatim when one fails rather than reaching for a flag that looks close. On `note list`, `-F` is `--output` and pairs with `--jq`; `--state` takes `all`, `resolved`, or `unresolved`, and `--type` takes `all`, `general`, `diff`, or `system`. `--reply` accepts a full discussion ID or a prefix of at least 8 characters, and passing a shorter one is an error to report rather than a prefix to pad. `--line` takes a single number or a range written `10:15`.

`refs/merge-requests/<iid>/head` is served by the project itself and is the MR's own head commit, so an MR from a fork fetches through `origin` with no fork remote added. That namespace is transcribed from GitLab's published reference rather than from a CLI, so a fetch that fails reports git's own error and stops the run; never guess a neighbouring ref name.

`glab mr approve` takes no body flag: an approval carries no message, so a summary meant to be recorded goes up as a separate `comment` first.

`--line` and `--old-line` each require `--file` and cannot be combined. `--file`, `--reply`, and `--unique` are mutually exclusive, so anchored comments cannot use `--unique`: there is no CLI-side double-post guard. `--resolvable=false` cannot combine with `--file`; leave it off, since each finding is meant to be a resolvable thread.

Comments land on the latest diff version. If `<head-sha>` is not the MR's current `.sha`, stop and report rather than posting -- the anchors were read against a diff that is no longer current.

Never resolve or unresolve a discussion -- `note resolve` exists and is never a substitute for an operation that was actually named.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `glab` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://gitlab.com/gitlab-org/cli> and stop.
