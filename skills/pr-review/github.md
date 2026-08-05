# GitHub Commands

Read when the forge resolves to GitHub. The suggestion fence, the verdict mapping, finding numbering, and the Voice rules are already loaded from `SKILL.md` and are not repeated here.

Every comment body travels as a file path -- the summary line, the anchor, and any suggestion block have to arrive byte-exact, so write each body to a temp file outside the repo and let `--body-file` or `@<path>` pass the bytes.

| Operation | Command |
| --- | --- |
| `auth` | `gh auth status` |
| `repo-id` | `gh repo view --json nameWithOwner --jq .nameWithOwner` |
| `view` | `gh pr view <id> --json number,title,body,author,headRefName,baseRefName,headRefOid,state,isDraft,url` |
| `diff` | `gh pr diff <id>` |
| `fetch-ref` | `git fetch origin refs/pull/<n>/head` |
| `threads` | `gh pr view <id> --comments` |
| `thread-list` | `gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] \| {id,path,line,in_reply_to_id,user:.user.login,body}'` |
| `reply` | `gh api --method POST repos/{owner}/{repo}/pulls/<n>/comments/<comment-id>/replies -F body=@<body-file>` |
| `comment` | see anchoring below |
| `review-batch` | see Batched Review below |
| `approve` | `gh pr review <id> --approve --body-file <body-file>` |
| `request-changes` | `gh pr review <id> --request-changes --body-file <body-file>` |
| `review-comment` | `gh pr review <id> --comment --body-file <body-file>` |
| `revoke` | no CLI equivalent -- see Dismissal below |

Anchored comments have no first-class command and go through the API. `commit_id` is required and must be the head SHA that was read:

```sh
# anchored line: side=RIGHT for the new version, LEFT for a removed line
gh api repos/{owner}/{repo}/pulls/<n>/comments \
  -f commit_id=<head-sha> -f path=<path> -F line=<n> -f side=RIGHT -F body=@<body-file>

# multi-line range: add -F start_line=<n> -f start_side=RIGHT
# whole file:       drop line/side, add -f subject_type=file
# no file anchor:   gh pr comment <id> --body-file <body-file>
```

## Flags That Bite

`{owner}` and `{repo}` are placeholders `gh api` fills from the working directory -- pass them literally. `-F` types its value and reads from a file when it starts with `@`; `-f` is always a raw string. So `line` and `start_line` take `-F`, `side` takes `-f`.

`gh pr diff` has no `--raw`; plain is the unified diff. `--json` fields are camelCase and the head SHA is `headRefOid`.

`refs/pull/<n>/head` is served by the base repo and is the PR's own head commit rather than a preview of the merge, so a PR opened from a fork fetches through `origin` with no fork remote added. FETCH_HEAD after that fetch equals `headRefOid`; check the SHA out by name anyway, since any later fetch overwrites FETCH_HEAD.

Comments post immediately, each its own thread, with no CLI-side double-post guard. A stale `commit_id` is rejected rather than relocated: if `<head-sha>` is not the PR's current `headRefOid`, stop and report rather than posting, since the anchors were read against a diff that is no longer current.

`reply` has no `gh` subcommand and its endpoint is transcribed from the REST reference rather than from `gh --help`; report the API's own error verbatim rather than substituting a path that looks close. That listing carries no resolution state -- resolved and unresolved threads are a GraphQL concept on GitHub -- so report the state as unavailable rather than inferring it.

## Batched Review

One review carrying every inline comment and the verdict, in a single call:

```sh
gh api --method POST repos/{owner}/{repo}/pulls/<n>/reviews --input <json-file>
```

```json
{
  "commit_id": "<head-sha>",
  "event": "APPROVE | REQUEST_CHANGES | COMMENT",
  "body": "<summary>",
  "comments": [
    {"path": "<path>", "line": 12, "side": "RIGHT", "body": "<text>"},
    {"path": "<path>", "start_line": 10, "start_side": "RIGHT", "line": 12, "side": "RIGHT", "body": "<text>"}
  ]
}
```

Every entry in `comments[]` needs a path and a line: `subject_type=file` is not accepted here, so a file-level or unanchored finding belongs in `body`. One rejected entry fails the whole review -- report it and stop, never resubmit without the offending comment, since a review missing a finding the report listed is not the review that was ordered.

## Dismissal

GitHub has no revoke. Dismissing needs the review id and elevated access:

```sh
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '.[] | {id,user:.user.login,state}'
gh api --method PUT repos/{owner}/{repo}/pulls/<n>/reviews/<review-id>/dismissals -f message=<reason>
```

If the id is ambiguous or access is refused, report it unsupported rather than dismissing a review the user did not name.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `gh` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://cli.github.com> and stop.
