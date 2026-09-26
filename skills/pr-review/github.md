# GitHub Commands

Read when the forge is GitHub; `SKILL.md` is already loaded. Bodies go through `--body-file` or `@<path>`.

| Operation | Command |
| --- | --- |
| `auth` | `gh auth status` |
| `repo-id` | `gh repo view --json nameWithOwner --jq .nameWithOwner` |
| `view` | `gh pr view <id> --json number,title,body,author,headRefName,baseRefName,headRefOid,state,isDraft,url` |
| `diff` | `gh pr diff <id>` |
| `fetch-ref` | `git fetch origin refs/pull/<n>/head` |
| `threads` | `gh pr view <id> --comments` |
| `comment-list` | `gh api repos/{owner}/{repo}/issues/<n>/comments --jq '.[] \| {id,user:.user.login,html_url,body}'` |
| `thread-list` | `gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] \| {id,path,line,in_reply_to_id,user:.user.login,body}'` |
| `reply` | `gh api --method POST repos/{owner}/{repo}/pulls/<n>/comments/<comment-id>/replies -F body=@<body-file>` |
| `comment` | see anchoring below |
| `review-batch` | see Batched Review below |
| `approve` | `gh pr review <id> --approve` |
| `revoke` | no CLI equivalent -- see Dismissal below |

Anchored comments go through the API. `commit_id` is required and must be the head SHA you read:

```sh
# anchored line: side=RIGHT for the new version, LEFT for a removed line
gh api repos/{owner}/{repo}/pulls/<n>/comments \
  -f commit_id=<head-sha> -f path=<path> -F line=<n> -f side=RIGHT -F body=@<body-file>

# whole file:       drop line/side, add -f subject_type=file
# no file anchor:   gh pr comment <id> --body-file <body-file>
```

## Flags That Bite

- Pass `{owner}` and `{repo}` literally; `gh api` fills them from the working directory.
- `-F` types its value and reads a file when it starts with `@`; `-f` is always a raw string. So `line` takes `-F`, `side` takes `-f`. Every comment anchors to one line, so never pass `start_line` or `start_side`.
- `gh pr diff` has no `--raw`; plain output is the unified diff. `--json` fields are camelCase; the head SHA is `headRefOid`.
- The base repo serves `refs/pull/<n>/head`, the PR's own head rather than a merge preview, so fork PRs fetch through `origin` with no extra remote. FETCH_HEAD then equals `headRefOid`, but check out the SHA by name, since later fetches overwrite FETCH_HEAD.
- Comments post immediately, each its own thread, with no double-post guard.
- A stale `commit_id` is rejected, not relocated: if `<head-sha>` isn't the current `headRefOid`, stop and report instead of posting.
- `reply` has no `gh` subcommand. It takes the id of the thread's first comment (the `thread-list` entry with a null `in_reply_to_id`).
- `comment-list` returns general conversation comments, which have no reply endpoint, so a finding linked to one uses its `html_url` (confirmed against `gh` 2.100.0 on a read).
- The review-comment listing has no resolution state, which exists only in GitHub's GraphQL API; report it as unavailable.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `gh` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://cli.github.com> and stop.

**Verification note.** The `reply` endpoint and its first-comment id, a stale `commit_id` being rejected, and one bad entry failing a whole batched review all come from the REST reference, not `gh --help` or a real PR. If the API behaves differently, report what it returns verbatim; never retry around it or try a similar-looking path.

## Batched Review

One call carries every anchored comment and the verdict, with no `body`:

```sh
gh api --method POST repos/{owner}/{repo}/pulls/<n>/reviews --input <json-file>
```

```json
{
  "commit_id": "<head-sha>",
  "event": "APPROVE | REQUEST_CHANGES | COMMENT",
  "comments": [
    {"path": "<path>", "line": 12, "side": "RIGHT", "body": "<text>"}
  ]
}
```

Here bodies go inside JSON strings, so build the file with `jq --rawfile`, one per body, never by hand:

```sh
jq -n --rawfile b2 <body-file-2> \
  '{commit_id:"<head-sha>", event:"COMMENT",
    comments:[{path:"<path>", line:12, side:"RIGHT", body:$b2}]}' > <json-file>
```

- `--rawfile` reads the file as one escaped string, so bytes arrive unchanged (checked with jq 1.8.2 on a body with a code fence, a tab, and double quotes).
- `jq` missing: say so and post the findings one at a time with `comment`; never hand-escape the payload.
- Every `comments[]` entry needs a path and a line, since `subject_type=file` isn't accepted here. File-level and unanchored findings post separately with `comment` after the review lands, never in `body`.
- The REST reference lists `body` as required for `REQUEST_CHANGES` and `COMMENT`; whether a non-empty `comments[]` suffices is untested. If the API rejects the missing body, report the error and stop; never add a summary to get past it.
- One rejected entry fails the whole review: report it and stop. Never resubmit without it, since a review missing a listed finding isn't the review requested.

## Dismissal

GitHub has no revoke. Dismissing needs the review id and elevated access:

```sh
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '.[] | {id,user:.user.login,state}'
gh api --method PUT repos/{owner}/{repo}/pulls/<n>/reviews/<review-id>/dismissals -f message=<reason>
```

If the id is ambiguous or access is refused, report it unsupported; never dismiss a review the user didn't name.
