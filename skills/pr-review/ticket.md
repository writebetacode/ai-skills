# Ticket Commands

Read this when a ticket is involved, from the Workflow in `SKILL.md`. The tracker is independent of the forge, so a GitHub PR can easily carry a Jira key.

| Tracker | Read |
| --- | --- |
| Jira | `acli jira auth status`, then `acli jira workitem view <key> --json --fields key,issuetype,summary,status,description,comment` |
| GitHub issue | `gh issue view <n> --json number,title,body,state,labels,url,comments`, plus `-R <owner>/<repo>` for one outside the repo under review |
| GitLab issue | `glab issue view <id> --output json`, plus `--comments` for the discussion and `-R <owner>/<repo>` for one outside the repo under review |
| Anything else | `WebFetch` on the ticket URL |

`PROJ-123` is a Jira key. A bare `#<n>` is an issue on the repo under review, read with the forge already resolved. A URL names its own tracker and is read with that tracker's command. Only a URL that matches none of the three goes to `WebFetch`, which can't get past a login; report that instead of returning a login page.

Read the description and the comments. Acceptance criteria are often settled in the thread, and never raise a finding against a requirement that was dropped there.

**Verification note.** These commands come from `acli` 1.3.22-stable, `gh` 2.97.0, and `glab` 1.113.0. If a command is rejected as unknown, the local version is different: report the CLI's own error word for word instead of trying a similar-looking flag.

If the ticket can't be read, mark it unread in the report and continue the review without it. That covers a missing CLI (`command not found`, exit 127), an `auth status` showing no account or one on another site, a key the tracker doesn't have, and a URL that won't fetch. Never infer what a ticket asks for from the branch name, the PR title, or the change's own description of it, and never install or authenticate a CLI for the user.
