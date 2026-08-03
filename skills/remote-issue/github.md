# GitHub Commands

Read when the tracker is GitHub. The body template, the field mapping, and the title rules are already loaded from `SKILL.md` and are not repeated here.

Descriptions always travel as file paths -- let `--body-file` pass the bytes, and never retype body text into a command.

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

On `issue-create`, `--title` and `--body-file` are both mandatory -- without them `gh` discards the composed body and prompts interactively, hanging a non-interactive run. `-e, --editor` does the same and is never passed. `--assignee @me` works, so assignment needs no username lookup.

GitHub issue types are an org-level feature many repos do not enable, so `--type` goes up only when the user asks for it explicitly; the body's `## Type` section carries it otherwise. A type the repo does not define is rejected by the API, and that rejection is reported rather than retried against a type picked here.

`--reason` on `issue-close` accepts `completed`, `not planned`, or `duplicate` and nothing else.

On `issue-edit`, the label and assignee flags are add/remove pairs rather than a replacing set; `--milestone`, `--type`, and `--parent` replace, each cleared by its own `--remove-*`. `--parent` names the parent from the child's side and takes an issue number or URL, so a sub-issue is attached by editing the child; `--add-sub-issue` and `--remove-sub-issue` do it from the parent's side instead, naming the child.

Report the CLI's own error rather than retrying a failed command with different flags, and never invent a flag absent from the table above -- an operation it does not cover is unsupported.

When `gh` is absent -- `command not found`, exit 127 -- that is not an auth failure: tell the user to install it from <https://cli.github.com> and stop.
