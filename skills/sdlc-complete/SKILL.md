---
name: sdlc-complete
description: Archive a finished SDLC project -- move its plans folder into plans/complete/ under a date-stamped name, then delete the local branches its tasks left behind. Use when a project is finished and being wrapped up, when the last task has merged and the plan folder should be put away, or when asking to clean up the branches a project left behind.
argument-hint: "[project-dir]"
---

# Complete

Flow: design -> implement -> **[complete]**

## Archive

Take the target from the arguments or a task file path, or ask the user, and walk up to the project folder holding `MANIFEST.md`. Read the manifest. If every epic is "Complete", show the source and target paths; otherwise list the incomplete epics and ask whether to go ahead anyway.

Move the whole project folder to `plans/complete/YYYYMMDD-<project-slug>/` with today's date, which leaves the slug free for reuse. If the target already exists (same slug, same day), stop and report it: `mv` would nest the project inside the earlier archive instead of refusing.

## Branch Cleanup

Collect branch names from every task file's `Branch` field. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `HEAD branch:` from `git remote show origin`; never assume `main`. Switch to it if needed.

A branch is deletable only when merging it into the default branch would change nothing. Ancestry and diffs can't tell: after a squash merge `git branch -d` says "not merged", and a diff flags the squashed changes plus, below the top of a stack, the default branch's later work. Compare trees:

```sh
git merge-tree --write-tree <default-branch> <branch>  # merged tree OID, non-zero exit on conflict
git rev-parse <default-branch>^{tree}                  # what it must equal
```

- Equal trees: delete with `git branch -D`.
- A different tree, a conflict, or any non-zero exit: unmerged work, so warn and skip.
- `--write-tree` rejected as unknown (it needs git 2.38+): report every branch unverified and skip them all. Never fall back to a weaker test.

The permission layer prompts before each deletion; expect one prompt per branch and never work around it.

Report the deleted branches, the skipped ones with reasons, total epics and tasks completed, and the time from manifest creation to completion.

## Rules

Never archive without explicit confirmation. Never delete a branch unless its merged tree was verified equal to the resolved default branch's. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
