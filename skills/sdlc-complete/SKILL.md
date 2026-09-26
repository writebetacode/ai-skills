---
name: sdlc-complete
description: Archive a finished SDLC project -- move its plans folder into plans/complete/ under a date-stamped name, then delete the local branches its tasks left behind. Use when a project is finished and being wrapped up, when the last task has merged and the plan folder should be put away, or when asking to clean up the branches a project left behind.
argument-hint: "[project-dir]"
---

# Complete

Flow: design -> implement -> **[complete]**

## Workflow

Take the target from the arguments or a task file path, or ask the user. Walk up from an epic or task path to the project folder holding `MANIFEST.md`. Read the manifest. If every epic is "Complete", show the source and target paths. Otherwise list the incomplete epics and ask whether to go ahead anyway. Move the whole project folder to `plans/complete/YYYYMMDD-<project-slug>/` with today's date, which leaves the original slug free for reuse. If the target already exists (same slug, same day), stop and report it, because `mv` would nest the project inside the earlier archive instead of refusing.

Next, collect branch names from the `Branch` field of every task file. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`). If that fails, parse `HEAD branch:` from `git remote show origin`. Never assume `main`. Switch to the default branch if you are not on it.

A branch can be deleted only when merging it into the default branch would change nothing. Ancestry and diffs can't answer that: after a squash merge `git branch -d` says "not merged", and a diff flags the squashed changes plus, on every branch below the top of a stack, the default branch's later work. Compare trees instead:

```sh
git merge-tree --write-tree <default-branch> <branch>  # merged tree OID, non-zero exit on conflict
git rev-parse <default-branch>^{tree}                  # what it must equal
```

If the trees are equal, delete the branch with `git branch -D`. A different tree, a conflict, or any non-zero exit means the branch has unmerged work: warn and skip it. `--write-tree` needs git 2.38 or newer. If git rejects it as unknown, report every branch as unverified and skip all of them. Never fall back to a weaker test. The permission layer prompts before each branch deletion. Expect one prompt per branch and never work around it.

Finish by reporting the deleted branches, the skipped ones and why, the total epics and tasks completed, and the time from manifest creation to completion.

## Rules

Never archive without explicit confirmation. Never delete a branch unless its merged tree was verified equal to the resolved default branch's tree. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
