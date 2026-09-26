# Jira Commands

Read when the tracker is Jira; `SKILL.md` is already loaded. Jira and `acli jira workitem` say "work item"; the user may say "issue". Descriptions go through `--description-file`.

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

The new work item's key and URL are only available from the create's `--json` output.

## Flags That Bite

- `--description` is inline text, `--description-file` reads a file; both take plain text or ADF, and plain text is sent unless the user asks for ADF.
- Never use `--from-file` (summary and description) or `--from-json` (a whole work item) in place of `--description-file`: each silently overrides fields set explicitly.
- `--project` is the *key* (`PROJ`), not the display name.
- `--assignee` accepts an email, account ID, `@me`, or `default`.
- `--type` is a type the project defines (`Epic`, `Story`, `Task`, `Bug`). Report a rejected type rather than retrying with one you picked.
- There's no `--priority`: priority can only be set via `--from-json` or a later edit, so it goes in the description. Never drop it.
- Never pass `-e, --editor`, which hangs. `--generate-json` writes a sample template and creates nothing.
- Auth is per Atlassian account and site. If `auth` shows no account, or one on another site, stop and report; `acli jira auth login` and `acli jira auth switch` are the user's to run.
- `edit`, `transition`, `assign`, and `delete` hang without `--yes`, and all four also accept `--jql` and `--filter`, which apply the operation to *every* match.
- `--status` on `transition` is a status name from the project's workflow; report a rejection rather than retrying with one you picked.
- On `comment create`, `--body-file` is `-F` and takes plain text or ADF. `--edit-last` rewrites the previous comment instead of adding one; use it only when asked.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `acli` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://developer.atlassian.com/cloud/acli/> and stop.

**Verification note.** Transcribed from `acli` 1.3.22-stable. A command rejected as unknown means the local version differs: report the CLI's own error verbatim rather than try a similar-looking flag.

**Irreversible violation:** running `issue-delete`, or scoping any write with `--jql` or `--filter` when the user named a key. Jira has no undelete, and a query-scoped write hits every match, so a JQL typo can transition or delete a backlog. "Clear out the stale tickets" is ambiguous, so ask; deleting a named key the user confirmed is acceptable.
