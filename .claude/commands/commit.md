---
name: commit
description: Create a conventional commit from staged changes. Use when the user wants to commit staged changes with a properly formatted commit message.
---

# Commit: Create Conventional Commit

```
<type>: <concise description>
```

## Commit Message Template

```
<type>: <description>

[optional body]

[optional trailers]
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## Workflow

Gather context by running `git status --short`, `git diff --cached`, `git branch --show-current`, and `git log --oneline -5` in parallel. If no files are staged, list the unstaged files, instruct the user to stage their changes first, and then stop. Analyze the branch prefix or the diff to infer the commit type, using any provided user input as additional context to draft a message in the imperative mood that is under 72 characters and focuses on purpose rather than mechanics. Present the drafted message to the user and ask `Commit? (yes/no/edit)`. On edit, accept the corrected text and re-confirm. Only after receiving explicit confirmation, execute the commit using a HEREDOC:

```bash
git commit -F - <<'EOF'
<type>: <message>
EOF
```

## Rules

Always work with currently staged files and never stage files automatically. Never commit or push without receiving explicit user confirmation first. Use HEREDOC for all commit messages to maintain formatting integrity. Trailer lines (e.g. `Refs: #123`, `Closes: #456`) may be added after a blank line when they provide useful context, but never include AI attribution, Co-Authored-By lines, or non-ASCII characters.

## User Input

$ARGUMENTS
