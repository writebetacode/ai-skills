# Jira Commands

Read this when the tracker is Jira. `SKILL.md` is already loaded. Jira and `acli jira workitem` say "work item", and the user may say either that or "issue". Descriptions go through `--description-file`.

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

The new work item's key and URL are only available from the `--json` output of the create.

## Flags That Bite

`--description` takes inline text and `--description-file` reads a file. Both accept plain text or ADF; send plain text unless the user asks for ADF. Never use `--from-file` (reads summary and description) or `--from-json` (a whole work item) instead of `--description-file`, because each silently overrides fields you set explicitly.

`--project` takes the project *key* (`PROJ`), not the display name. `--assignee` accepts an email, an account ID, `@me`, or `default`. `--type` is a work item type name the project defines (`Epic`, `Story`, `Task`, `Bug`). If the API rejects the type, report it instead of retrying with one you picked.

There is no `--priority` flag. Priority can only be set through `--from-json` or a later edit, so put it in the description. Never drop it.

Never pass `-e, --editor`, which hangs the run. `--generate-json` writes a sample template and creates nothing.

Auth is per Atlassian account and site. If `auth` shows no account, or an account on a different site from the one you're filing against, stop and report it. `acli jira auth login` and `acli jira auth switch` are for the user to run.

`edit`, `transition`, `assign`, and `delete` prompt for confirmation, and hang, unless given `--yes`. `--status` on `transition` is a status name from the project's workflow. If the workflow rejects it, report that instead of retrying with a name you picked. All four also accept `--jql` and `--filter`, which apply the operation to *every* matching work item. On `comment create`, `--body-file` is `-F` and takes plain text or ADF. `--edit-last` rewrites the previous comment instead of adding one, so use it only when the user asks.

**Verification note.** These commands come from `acli` 1.3.22-stable. If a command is rejected as unknown, the local version is different: report the CLI's own error word for word instead of trying a similar-looking flag.

**Irreversible violation:** running `issue-delete`, or scoping any write with `--jql` or `--filter` when the user named a key. Jira has no undelete, and a query-scoped write hits every match at once, so a JQL typo can transition or delete a whole backlog. "Clear out the stale tickets" is too ambiguous to act on, so ask. Deleting a named key after the user confirms is acceptable.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

If `acli` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://developer.atlassian.com/cloud/acli/> and stop.
