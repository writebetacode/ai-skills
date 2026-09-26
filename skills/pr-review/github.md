# GitHub Commands

Read this when the forge is GitHub. `SKILL.md` is already loaded. Bodies go through `--body-file` or `@<path>`.

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

Pass `{owner}` and `{repo}` literally; `gh api` fills them in from the working directory. `-F` types its value and reads a file when the value starts with `@`, while `-f` is always a raw string. So `line` takes `-F` and `side` takes `-f`. Every comment anchors to one line, so never pass `start_line` or `start_side`.

`gh pr diff` has no `--raw`; the plain output is the unified diff. `--json` fields are camelCase, and the head SHA is `headRefOid`.

The base repo serves `refs/pull/<n>/head`, which is the PR's own head commit rather than a merge preview, so fork PRs fetch through `origin` without adding a remote. After the fetch, FETCH_HEAD equals `headRefOid`, but check out the SHA by name anyway, since any later fetch overwrites FETCH_HEAD.

Comments post immediately, each as its own thread, and nothing stops a double post. A stale `commit_id` is rejected, not relocated. If `<head-sha>` isn't the PR's current `headRefOid`, stop and report instead of posting.

`reply` has no `gh` subcommand. Its endpoint, and the fact that it takes the id of the thread's first comment (the `thread-list` entry with a null `in_reply_to_id`), come from the REST reference, not from `gh --help`. Two other behaviours here also come from that reference and haven't been tested against a real PR: a stale `commit_id` being rejected, and one bad entry failing a whole batched review. If the API behaves differently, report what it actually returns, word for word. Never retry around it or try a similar-looking path. `comment-list` returns general conversation comments, which have no reply endpoint, so a finding linked to one uses its `html_url` (endpoint confirmed against `gh` 2.100.0 on a read). The review-comment listing has no resolution state, since resolved threads only exist in GitHub's GraphQL API, so report the state as unavailable.

## Batched Review

One review with every anchored comment and the verdict, in a single call, with no `body`:

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

Here the bodies go inside JSON strings instead of being passed as files. Build the JSON file with `jq --rawfile`, one per body, and never type a body into the JSON by hand:

```sh
jq -n --rawfile b2 <body-file-2> \
  '{commit_id:"<head-sha>", event:"COMMENT",
    comments:[{path:"<path>", line:12, side:"RIGHT", body:$b2}]}' > <json-file>
```

`--rawfile` reads the file as one escaped string, so the bytes arrive unchanged. This was checked with jq 1.8.2 on a body containing a code fence, a tab, and double quotes. If `jq` is missing, say so and post the findings one at a time with `comment`. Never hand-escape the payload.

Every entry in `comments[]` needs a path and a line. `subject_type=file` isn't accepted here, so file-level and unanchored findings are posted separately with `comment` after the review lands, never in `body`. The REST reference lists `body` as required for `REQUEST_CHANGES` and `COMMENT`, and it hasn't been tested whether a non-empty `comments[]` is enough. If the API rejects the missing body, report the error and stop. Never add a summary to get past it. If one entry is rejected, the whole review fails: report it and stop. Never resubmit without the rejected comment, because a review missing a finding from the report isn't the review that was requested.

## Dismissal

GitHub has no revoke. Dismissing a review needs its id and elevated access:

```sh
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '.[] | {id,user:.user.login,state}'
gh api --method PUT repos/{owner}/{repo}/pulls/<n>/reviews/<review-id>/dismissals -f message=<reason>
```

If the id is ambiguous or access is refused, report it as unsupported. Never dismiss a review the user didn't name.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

If `gh` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://cli.github.com> and stop.
