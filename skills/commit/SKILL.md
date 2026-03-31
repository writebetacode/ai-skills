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

Gather context by running `git diff --cached`, `git branch --show-current`, and `git log --oneline -5` in parallel. If `git diff --cached` returns empty output, no files are staged -- run `git status --short` to list the working tree, instruct the user to stage their changes first, and stop. Analyze the branch prefix or the diff to infer the commit type, defaulting to `chore` when neither the branch prefix nor diff content maps to a specific type, and use any provided user input as additional context to draft a message in the imperative mood that is under 72 characters and focuses on purpose rather than mechanics. Execute the commit immediately using a HEREDOC:

```bash
git commit -F - <<'EOF'
<type>: <message>
EOF
```

## Rules

Always work with currently staged files and never stage files automatically. Use HEREDOC for all commit messages to maintain formatting integrity. Trailer lines (e.g. `Refs: #123`, `Closes: #456`) may be added after a blank line when they provide useful context. Use only ASCII characters and never include AI attribution or "Co-Authored-By" lines in any output.

## User Input

$ARGUMENTS
