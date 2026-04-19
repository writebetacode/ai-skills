---
name: commit
description: Create a conventional commit from staged changes. Use when the user wants to commit staged changes with a properly formatted commit message.
model: sonnet
---

# Commit: Create Conventional Commit

## Message Template

```
<type>: <description>

[optional body]

[optional trailers]
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## Workflow

Gather context in parallel by running `git diff --cached --name-only` to enumerate staged files, `git diff --cached` for the actual changes, `git branch --show-current`, and `git log --oneline -5`. Treat the `--name-only` list as the authoritative check: if it is empty, nothing is staged — run `git status --short`, tell the user to stage their changes first, and stop. If any files appear in the list, treat every one of them as in-scope for this commit regardless of how or why it was staged. Infer the commit type from the branch prefix or diff content, defaulting to `chore` when neither maps cleanly, and use any provided user input as additional context. Draft a message in the imperative mood under 72 characters that focuses on purpose rather than mechanics. Execute the commit immediately via HEREDOC:

```bash
git commit -F - <<'EOF'
<type>: <message>
EOF
```

## Rules

Commit every file currently in the index exactly as the user has staged it — the user's staging is authoritative and may include files staged externally from the AI conversation. Never run `git reset`, `git restore --staged`, `git rm --cached`, or any other command that removes or alters entries in the index, and never suggest excluding a staged file. Never stage files automatically. Use HEREDOC for all commit messages to preserve formatting. Trailer lines (e.g. `Refs: #123`, `Closes: #456`) may be added after a blank line when they provide useful context. Use only ASCII and never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
