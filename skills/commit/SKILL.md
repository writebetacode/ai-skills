---
name: commit
description: Create a conventional commit from staged changes. Use when the user wants to commit staged changes with a properly formatted commit message.
argument-hint: "[extra context for the message]"
allowed-tools: "Bash(git diff --cached:*), Bash(git branch --show-current:*), Bash(git log --oneline:*), Bash(git status --short:*)"
---

# Commit

## Workflow

Gather in parallel: `git diff --cached --name-only`, `git diff --cached`, `git branch --show-current`, `git log --oneline -5`. If `--name-only` is empty, run `git status --short`, tell the user to stage first, and stop.

Infer the type from the branch prefix or the diff, defaulting to `chore`: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`. Fold in any user input. Write the description in imperative mood, under 72 characters, about purpose rather than mechanics. Add a body when useful, and trailers (`Refs: #123`, `Closes: #456`) after a blank line.

```bash
git commit -F - <<'EOF'
<type>: <description>

[optional body]

[optional trailers]
EOF
```

If a hook rejects the commit, stop and report its output and what it objected to. Never retry with `--no-verify`. If a hook rewrites files, the commit is made and the rewritten copies are left unstaged. Tell the user, because the next commit picks them up.

## Rules

Commit right away with no confirmation step. A wrong type or wording gets fixed with `git commit --amend`, not prevented by asking first. Commit the index exactly as staged, including files staged outside this session. Never run `git reset`, `git restore --staged`, `git rm --cached`, or anything else that changes index entries. Never suggest leaving a staged file out, and never stage anything yourself. Always pass the message through a HEREDOC. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
