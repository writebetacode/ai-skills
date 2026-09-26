# Ticket Commands

Read when a ticket is in play, from `SKILL.md`'s Review section. The tracker is independent of the forge: a GitHub PR can easily carry a Jira key.

| Tracker | Read |
| --- | --- |
| Jira | `acli jira auth status`, then `acli jira workitem view <key> --json --fields key,issuetype,summary,status,description,comment` |
| GitHub issue | `gh issue view <n> --json number,title,body,state,labels,url,comments`, plus `-R <owner>/<repo>` for one outside the repo under review |
| GitLab issue | `glab issue view <id> --output json`, plus `--comments` for the discussion and `-R <owner>/<repo>` for one outside the repo under review |
| Anything else | `WebFetch` on the ticket URL |

- `PROJ-123` is a Jira key.
- A bare `#<n>` is an issue on the repo under review, read with the forge already resolved.
- A URL is read with its own tracker's command; only one matching none of the three goes to `WebFetch`, which can't pass a login, so report that instead of returning a login page.

Read the description and the comments: acceptance criteria are often settled in the thread, and never raise a finding against a requirement dropped there.

If the ticket can't be read, mark it unread in the report and review without it: a missing CLI (`command not found`, exit 127), an `auth status` with no account or one on another site, a key the tracker lacks, or a URL that won't fetch. Never infer what a ticket asks from the branch name, the PR title, or the change's own description of it, and never install or authenticate a CLI for the user.

**Verification note.** Transcribed from `acli` 1.3.22-stable, `gh` 2.97.0, and `glab` 1.113.0. A command rejected as unknown means the local version differs: report the CLI's own error verbatim rather than try a similar-looking flag.
