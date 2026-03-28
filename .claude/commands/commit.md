---
name: commit
description: Create a conventional commit from staged changes. Use when the user wants to commit staged changes with a properly formatted commit message.
model: sonnet
---

# Commit: Create Conventional Commit

```
<type>: <concise description>
```

## Workflow

Gather context by running `git status --short`, `git diff --cached`, `git branch --show-current`, and `git log --oneline -5` in parallel. If no files are staged, list the unstaged files, instruct the user to stage their changes first, and then stop. Analyze the branch prefix or the diff to infer the commit type, using any provided user input as additional context to draft a message in the imperative mood that is under 72 characters and focuses on purpose rather than mechanics. Present the drafted message to the user for confirmation, allowing them to edit the text if necessary. Only after receiving explicit confirmation, execute the commit using a HEREDOC:

```bash
git commit -F - <<'EOF'
<type>: <message>
EOF
```

## Rules

Always work with currently staged files and never stage files automatically. Never commit or push without receiving explicit user confirmation first. Use HEREDOC for all commit messages to maintain formatting integrity. Do not include any AI attribution, Co-Authored-By lines, or non-ASCII characters in the commit messages.

## User Input

$ARGUMENTS
