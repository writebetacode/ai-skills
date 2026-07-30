---
name: gh-release
description: Tag the default branch and publish a GitHub release, inferring the version from commit history and drafting notes in the repo's established voice. Use when cutting a release after work has merged.
---

# GitHub Release

Releases are GitHub-only here, so the backend is fixed: dispatch every remote operation to the `gh` agent via the `Agent` tool, resuming it with `SendMessage` for later operations in the same run. Send `op:` and its parameters one per line, and pass the release notes as a file path -- the bytes never travel as prose in a message. Git itself stays in this skill: tags, log, and remote resolution are local operations with no agent between them.

## Workflow

Dispatch `auth`; stop on failure. Resolve the default branch via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:`; never assume `main`. Check it out, `git pull`, and confirm the tree is clean -- refuse to release from a dirty tree or a non-default branch, naming what is in the way.

**Establish conventions from the repo, never from this file.** Read the existing tags with `git tag -l --sort=-v:refname` and the last few releases via `release-list` and `release-view`. Match what you find: tag format, title prefix, body structure, whether tags are annotated. The patterns below describe the common case, but an existing repo's actual history always wins.

**Resolve the version.** An explicit version in `$ARGUMENTS` wins outright -- normalize its `v` prefix to match existing tags. Otherwise infer: take the latest tag by `--sort=-v:refname` (never plain `sort`, which orders `v0.3.9` after `v0.3.10`), read `git log <latest>..HEAD --oneline`, and bump by the strongest change present -- a breaking change majors, any `feat` minors, otherwise patch. Below `1.0.0`, breaking changes bump the minor rather than the major. State the proposed version, the tag it follows, and the commit types that drove it, then confirm before tagging. If no commits separate HEAD from the latest tag, stop: there is nothing to release.

**Draft the notes.** Read the commits and their diffs, and group them by theme rather than listing them mechanically -- match the section structure of recent releases in this repo. Draft a title in the voice of the existing release titles, preserving any prefix convention. Where recent releases carry a section on what was and was not verified, write one honestly: name what was actually exercised and what was only inspected. Show the version, title, and full body, and let the user edit before anything is published.

**Close with the changelog range.** End the body with a compare link spanning the previous tag to the new one, matching the form recent releases use -- typically `**Full Changelog**: <remote-url>/compare/<previous-tag>...<new-tag>` as the last line. The previous tag is the one the version was inferred against, so the range covers exactly the commits described above it. Derive the URL from `git remote get-url origin`, converting an SSH remote (`git@host:owner/repo.git`) to its `https://host/owner/repo` form. On a repo's first release there is no previous tag: omit the link rather than inventing a range.

**Publish on confirmation.** Create an annotated tag (`git tag -a <version> -m <title>`) when the repo's recent tags are annotated, a lightweight tag when they are not; `git cat-file -t "$(git rev-parse <tag>)"` reports `tag` for annotated and `commit` for lightweight. Push it, then write the drafted body to a temp file outside the repo and dispatch `release-create` with the tag, target branch, title, and notes path. The agent passes `--verify-tag`, so a tag that never reached the remote fails the create rather than publishing a release that points at nothing. Ask for `--generate-notes` only when the drafted body is meant to carry gh's commit list beneath it. Display the release URL from the agent's report.

## Rules

Never publish without an explicit confirmation covering the final version, title, and body together. Never tag from a branch other than the resolved default branch, or from a dirty tree. Never reuse an existing tag -- check with `git rev-parse <version>` first and stop if it resolves. Never invent a version that skips or reorders the sequence.

Never claim in release notes that something was tested, verified, or exercised unless that actually happened in a way you can point to; describe inspected-only work as inspected. A release note is a public durable record, and an overstated one is worse than a terse one.

Never compose a remote command here. An operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call from this skill -- the tables are the single place those flags are maintained. The notes always travel as a file path, which is what keeps a body byte-exact through the handoff and out of reach of shell quoting.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Version violation:** any tag that breaks the repo's existing format -- a missing or added `v` prefix, a truncated `MAJOR.MINOR.PATCH`, or a number that does not follow the latest tag -- must be corrected before tagging.

**Title violation:** any title that drops the repo's established prefix convention, or that restates the version number instead of describing the release, must be rewritten before publishing.

## User Input

$ARGUMENTS
