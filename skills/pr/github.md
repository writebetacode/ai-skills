# GitHub Commands

Read when the forge resolves to GitHub. The body template, the update path, and the title and assignment rules are already loaded from `SKILL.md` and are not repeated here.

Bodies always travel as file paths -- let `--body-file` pass the bytes, and never retype body text into a command.

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

`--json` fields are camelCase and the head SHA is `headRefOid`. `--assignee @me` works, so assignment needs no username lookup.

Converting to draft is plan-dependent: `gh pr ready --undo` is refused on accounts where `gh pr ready` succeeds. Report the refusal as it stands rather than simulating the state another way.

On `edit`, the label, assignee, and reviewer flags are add/remove pairs rather than a replacing set, so removing one means naming it in `--remove-*`; `--milestone` does replace, and `--remove-milestone` clears it.

Naming `--head` costs `gh` the prompt it would otherwise raise to push an unpushed branch, so a head the remote does not have comes back as an error: report it and say the branch needs pushing, rather than pushing on the user's behalf.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `gh` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://cli.github.com> and stop.
