---
name: commit
description: Create a conventional commit from staged changes. Use when the user wants to commit staged changes with a properly formatted commit message.
model: sonnet
---

# Commit

## Message Template

```
<type>: <description>

[optional body]

[optional trailers]
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## Workflow

Gather context in parallel: `git diff --cached --name-only` (staged files), `git diff --cached` (full changes), `git branch --show-current`, `git log --oneline -5`. If `--name-only` is empty, nothing is staged — run `git status --short`, tell the user to stage first, stop. Infer commit type from branch prefix or diff content, defaulting to `chore` when neither maps cleanly; fold in any user input as context. Draft a message in imperative mood under 72 characters focusing on purpose, not mechanics. Execute immediately via HEREDOC:

```bash
git commit -F - <<'EOF'
<type>: <message>
EOF
```

<!-- response-style:v1 -->
## Response Style

Default to terse output: drop articles, filler ("just", "really"), and pleasantries; fragments and short clauses are fine; keep commands, paths, and templates verbatim. Disengage automatically for security warnings, irreversible-action confirmations, and any moment where ambiguity could cause user error — switch to full sentences. The user can say "discuss", "verbose", or "explain" to drop terse mode for the rest of the turn.

## Rules

Commit every file in the index exactly as staged — user staging is authoritative and may include files staged externally. Never run `git reset`, `git restore --staged`, `git rm --cached`, or anything that alters index entries; never suggest excluding a staged file. Never stage automatically. Use HEREDOC for all commit messages to preserve formatting. Trailer lines (`Refs: #123`, `Closes: #456`) may follow a blank line when useful. Use only ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
