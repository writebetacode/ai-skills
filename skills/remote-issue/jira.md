# Jira Commands

Read when the tracker is Jira. The body template, the field mapping, and the title rules are already loaded from `SKILL.md` and are not repeated here.

Jira calls them work items, not issues, and the CLI follows suit (`acli jira workitem`); the user may say either. Descriptions always travel as file paths -- let `--description-file` pass the bytes, and never retype description text into a command.

| Operation | Command |
| --- | --- |
| `auth` | `acli jira auth status` |
| `issue-view` | `acli jira workitem view <key> --json`, plus `--fields <a,b>` for a subset |
| `issue-create` | `acli jira workitem create --project <key> --type <type> --summary <summary> --description-file <path> --assignee @me --json`, plus `--label <a,b>` and `--parent <key>` when asked |
| `issue-search` | `acli jira workitem search --jql <jql> --json`, plus `--limit <n>`, `--fields <a,b>`, and `--paginate` when asked |
| `issue-edit` | `acli jira workitem edit --key <key> --yes --json`, plus `--summary`, `--description-file`, `--labels`, `--remove-labels`, `--type`, `--assignee`, and `--remove-assignee` as named |
| `issue-comment` | `acli jira workitem comment create --key <key> --body-file <body-file> --json` |
| `issue-comment-list` | `acli jira workitem comment list --key <key> --json`, plus `--limit <n>` and `--order <+created\|-created\|+updated\|-updated>` when asked |
| `issue-transition` | `acli jira workitem transition --key <key> --status <status> --yes --json` |
| `issue-assign` | `acli jira workitem assign --key <key> --assignee <assignee> --yes --json`, plus `--remove-assignee` when asked |
| `issue-delete` | `acli jira workitem delete --key <key> --yes --json` |

Project key, work item type, and summary are required on create and never invented -- ask the user rather than guessing. On a successful create, the new work item key and URL come from the `--json` output and there is no other way to learn them.

## Flags That Bite

`--description` takes inline text, `--description-file` reads a file; both accept plain text or ADF, and plain text is what this skill sends unless the user asks for ADF. Never substitute `--from-file` (which reads *both* summary and description) or `--from-json` (a whole work item definition) for `--description-file`: each silently takes over fields that were set explicitly.

`--project` is the project *key* (`PROJ`), not the display name. `--assignee` accepts an email, an account ID, `@me`, or `default`. `--type` is the work item type name as that project defines it (`Epic`, `Story`, `Task`, `Bug`); a type the project lacks is rejected by the API, and that rejection is reported rather than retried against a type picked here.

There is no `--priority` flag -- priority reaches Jira through `--from-json` or a later `edit`, so priority belongs in the description. Do not quietly drop it.

`-e, --editor` hangs a non-interactive run; never pass it. `--generate-json` writes a sample template and creates nothing.

Authentication is per Atlassian account and site. If `auth` reports no account, or one for a site other than the one being filed against, stop and report -- `acli jira auth login` and `acli jira auth switch` are the user's to run.

`edit`, `transition`, `assign`, and `delete` prompt for confirmation without `--yes` and hang a non-interactive run. Each also accepts `--jql` and `--filter`, which apply the operation to *every* work item the query returns. On `comment create`, `--body-file` is `-F` and takes plain text or ADF; `--edit-last` rewrites the previous comment instead of adding one, so it goes only where the user asks for it.

**Verification note.** These commands are transcribed from `acli` 1.3.22-stable. If an invocation is rejected as unknown the local version differs: report the CLI's own error verbatim rather than substituting a flag that looks close.

**Irreversible violation:** running `issue-delete`, or scoping any write with `--jql` or `--filter` where the user named a key. Jira has no undelete, and a query-scoped write hits every match at once, so a mistyped JQL transitions or deletes a backlog rather than a ticket. "Clear out the stale tickets" is a violation to bring back as ambiguous; a delete of a named key, confirmed by the user, is acceptable.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `acli` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://developer.atlassian.com/cloud/acli/> and stop.
