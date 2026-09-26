# GitHub Commands

Read when the tracker is GitHub; `SKILL.md` is already loaded. Bodies go through `--body-file`.

| Operation | Command |
| --- | --- |
| `auth` | `gh auth status` |
| `repo-id` | `gh repo view --json nameWithOwner --jq .nameWithOwner` |
| `whoami` | `gh api user --jq .login` |
| `issue-view` | `gh issue view <n> --json number,title,state,url` |
| `issue-create` | `gh issue create --title <title> --body-file <body-file> --assignee @me`, plus `--label`, `--type`, and `--parent` when asked |
| `issue-list` | `gh issue list --limit <n> --json number,title,state,labels,assignees,url` |
| `issue-edit` | `gh issue edit <n>`, plus `--title`, `--body-file`, `--add-label`, `--remove-label`, `--add-assignee`, `--remove-assignee`, `--milestone`, `--remove-milestone`, `--type`, `--remove-type`, `--parent`, `--remove-parent`, `--add-sub-issue`, and `--remove-sub-issue` as named |
| `issue-comment` | `gh issue comment <n> --body-file <body-file>` |
| `issue-close` | `gh issue close <n>`, plus `--reason <completed\|not planned\|duplicate>` and `--comment <text>` when asked |
| `issue-reopen` | `gh issue reopen <n>` |

## Flags That Bite

- `issue-create` needs both `--title` and `--body-file`, or `gh` drops the body and prompts, hanging the run. Never pass `-e, --editor`, which does the same.
- `--assignee @me` works, so no username lookup is needed.
- Issue types are an org-level feature many repos lack: pass `--type` only when asked, and let the body's `## Type` carry it otherwise. Report a rejected type rather than retrying with one you picked.
- `--reason` on `issue-close` accepts only `completed`, `not planned`, or `duplicate`.
- On `issue-edit`, labels and assignees are add/remove pairs; `--milestone`, `--type`, and `--parent` replace, each with its own `--remove-*`. `--parent` is set from the child, taking an issue number or URL; `--add-sub-issue` and `--remove-sub-issue` do it from the parent, naming the child.
- On failure, report the CLI's own error rather than retrying with other flags, and never use a flag missing from the table.
- `gh` missing (`command not found`, exit 127) isn't an auth failure: tell the user to install it from <https://cli.github.com> and stop.
