# GitHub Commands

Read this when the forge is GitHub. `SKILL.md` is already loaded. Bodies go through `--body-file`.

| Operation | Command |
| --- | --- |
| `auth` | `gh auth status` |
| `repo-id` | `gh repo view --json nameWithOwner --jq .nameWithOwner` |
| `whoami` | `gh api user --jq .login` |
| `view` | `gh pr view <id> --json number,title,body,author,headRefName,baseRefName,headRefOid,state,isDraft,url` |
| `description` | `gh pr view <id> --json body --jq .body` |
| `list` | `gh pr list --limit <n> --json number,title,author,headRefName,baseRefName,state,isDraft,url` |
| `status` | `gh pr status` |
| `checks` | `gh pr checks <id>` |
| `issue-view` | `gh issue view <n> --json number,title,state,url` |
| `create` | `gh pr create --title <title> --body-file <body-file> --base <base> --head <head> --assignee @me`, plus `--draft` when asked |
| `update-description` | `gh pr edit <id> --body-file <body-file>` |
| `title` | `gh pr edit <id> --title <title>` |
| `edit` | `gh pr edit <id>`, plus `--add-label`, `--remove-label`, `--add-assignee`, `--remove-assignee`, `--add-reviewer`, `--remove-reviewer`, `--milestone`, and `--base` as named |
| `draft` | `gh pr ready <id> --undo` |
| `ready` | `gh pr ready <id>` |

## Flags That Bite

`--json` fields are camelCase, and the head SHA is `headRefOid`. `--assignee @me` works, so no username lookup is needed.

Converting to draft depends on the plan: some accounts refuse `gh pr ready --undo` even though `gh pr ready` works.

On `edit`, labels, assignees, and reviewers are add/remove pairs, so removing one means naming it in `--remove-*`. `--milestone` replaces, and `--remove-milestone` clears it.

With `--head` named, `gh` doesn't offer to push an unpushed branch. A head missing from the remote comes back as an error, which is why the head is pushed before `create`.

If a command fails, report the CLI's own error instead of retrying with different flags. Never use a flag that isn't in the table.

If `gh` is missing (`command not found`, exit 127), that is not an auth failure. Tell the user to install it from <https://cli.github.com> and stop.
