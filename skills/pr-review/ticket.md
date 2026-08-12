# Ticket Commands

Read when a ticket is in play, from the Workflow in `SKILL.md`. The forge's own reference file is already loaded from there; the tracker a ticket lives in is independent of it, so a GitHub PR routinely carries a Jira key.

| Tracker | Read |
| --- | --- |
| Jira | `acli jira auth status`, then `acli jira workitem view <key> --json --fields key,issuetype,summary,status,description,comment` |
| GitHub issue | `gh issue view <n> --json number,title,body,state,labels,url,comments`, plus `-R <owner>/<repo>` for one outside the repo under review |
| GitLab issue | `glab issue view <id> --output json`, plus `--comments` for the discussion and `-R <owner>/<repo>` for one outside the repo under review |
| Anything else | `WebFetch` on the ticket URL |

`PROJ-123` is a Jira key. A bare `#<n>` is an issue on the repo under review, read with the forge already resolved. A URL names its own tracker and is read with that tracker's command; only a URL matching none of the three falls to `WebFetch`, which reaches nothing behind a login and reports that rather than returning a page that says so.

Read the description and the comments both: acceptance criteria are as often negotiated in the thread as written in the body, and a requirement dropped in discussion is one a finding must not be raised against.

**Verification note.** Transcribed from `acli` 1.3.22-stable, `gh` 2.97.0, and `glab` 1.113.0. If an invocation is rejected as unknown the local version differs: report the CLI's own error verbatim rather than substituting a flag that looks close.

A ticket that cannot be read is reported as unread in the report and the review continues without it -- an absent CLI (`command not found`, exit 127), a `auth status` that reports no account or an account on another site, a key the tracker does not have, or a URL that will not fetch. Never infer what a ticket asks for from the branch name, the PR title, or the change's own summary of it, and never install or authenticate a CLI on the user's behalf.
