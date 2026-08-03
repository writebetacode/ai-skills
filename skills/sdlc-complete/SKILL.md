---
name: sdlc-complete
description: Archive a finished SDLC project -- move its plans folder into plans/complete/ under a date-stamped name, then delete the local branches its tasks left behind. Use when a project is finished and being wrapped up, when the last task has merged and the plan folder should be put away, or when asking to clean up the branches a project left behind.
argument-hint: "[project-dir]"
---

# Complete

Flow: design -> implement -> **[complete]**

## Workflow

Resolve the target from the arguments, a task file path, or by prompting the user, landing on the project folder containing `MANIFEST.md`; if given an epic or task path, walk up to the project root. Read the manifest, check whether all epics are "Complete". If so, present the source and target archival paths. If some remain incomplete, list them and ask whether to proceed anyway. Move the entire project folder -- manifest, research, epics, tasks, supporting files -- to `plans/complete/YYYYMMDD-<project-slug>/` (today's date). Date appends at archive time so the original slug can be reused without collision. Where that target path already exists -- a second archive of the same slug on the same day -- stop and report it: `mv` would nest the project inside the earlier archive rather than refuse.

After archiving, collect branch names from each task file's `Branch` field. Resolve the repo's default branch via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:`; never assume `main`, since the repo may default to `develop`, `master`, or `trunk`. Switch to it if needed.

A branch is deletable only when merging it into the default branch would change nothing. Ancestry cannot decide that -- a squash merge leaves `git branch -d` reporting "not merged" -- and neither can a diff, which reports a squashed branch's own changes as unmerged and reports the default branch's later work as a difference on every branch below the top of a stack:

```sh
git merge-tree --write-tree <default-branch> <branch>  # merged tree OID, non-zero exit on conflict
git rev-parse <default-branch>^{tree}                  # what it must equal
```

Equal trees mean the branch's changes are already in the default branch: delete it with `git branch -D`. A differing tree, a conflict, or any non-zero exit means unmerged work -- warn and skip. `--write-tree` needs git 2.38 or newer; where it is rejected as unknown, report every branch unverified and skip them all rather than falling back to a weaker test. The permission layer asks before every branch deletion, so expect a prompt per branch and never work around it. Final report: deleted branches (and any skipped with reasons), total epics, total tasks completed, timeline from manifest creation to completion.

## Rules

Never archive without explicit confirmation. Never delete a branch whose merged tree was not verified equal to the resolved default branch's -- warn and skip it instead. Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

## User Input

$ARGUMENTS
