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

1. **Context Discovery**: Run `git status --short`, `git diff --cached`, `git branch --show-current`, and `git log --oneline -5` in parallel.
   - If no files are staged, list unstaged files, tell the user to stage changes first, and stop.
2. **Analyze & Draft**: Infer commit type from branch prefix (`feat/`, `fix/`, `chore/`, etc.) or diff. Use `$ARGUMENTS` as extra context. Write message in imperative mood, under 72 chars, purpose not mechanics.
3. **Confirm**: Show the message and ask `Commit? (yes/no/edit)`.
   - On **edit**: accept the corrected text from the user and re-confirm.
4. **Execute**: Only after confirmation, commit via HEREDOC:
   ```bash
   git commit -F - <<'EOF'
   <type>: <message>
   EOF
   ```

## Rules

- Never stage files — only work with what is already staged
- Never commit without user confirmation
- Never push
- Always use HEREDOC for the commit message
- NEVER add Co-Authored-By or any AI attribution lines to commit messages — ASCII only

## User Input

$ARGUMENTS
