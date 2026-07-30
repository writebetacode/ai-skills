---
name: remote-release
description: Tag the default branch and publish a release on GitHub or GitLab, inferring the version from commit history and drafting notes in the repo's established voice. Use when cutting a release after work has merged.
---

# Remote Release

One skill for both forges. The commands belong to the `gh` and `glab` agents; what follows is host-agnostic.

## Host

Resolve the forge from the `origin` remote and dispatch every remote operation to that host's agent -- `gh` for GitHub, `glab` for GitLab -- via the `Agent` tool, resuming it with `SendMessage` within a run. Where a self-hosted URL settles nothing, ask each available agent for `repo-id` and take the one that resolves; if both do or neither does, ask the user.

Two failures stop the run rather than routing around it. If the agent cannot be spawned, it is excluded in `config.yml` or not installed: name it and say so. If it reports the CLI missing, tell the user which CLI to install, with the URL it gave. Never fall back to running the command here -- and never tag or push on the way to a release you cannot then publish.

Send `op:` and its parameters one per line, and pass the release notes as a file path -- the bytes never travel as prose in a message, which is what keeps a body byte-exact and out of reach of shell quoting. Git stays in this skill: tags, log, and remote resolution are local operations with no agent between them.

## Workflow

Dispatch `auth`; stop on failure. Resolve the default branch via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:`; never assume `main`. Check it out, `git pull`, and confirm the tree is clean -- refuse to release from a dirty tree or a non-default branch, naming what is in the way.

**Establish conventions from the repo, never from this file.** Read existing tags with `git tag -l --sort=-v:refname` and recent releases via `release-list` and `release-view`. Match what you find: tag format, title prefix, body structure, whether tags are annotated. The patterns below describe the common case; the repo's actual history always wins.

**Resolve the version.** An explicit version in `$ARGUMENTS` wins outright -- normalize its `v` prefix to match existing tags. Otherwise take the latest tag by `--sort=-v:refname` (never plain `sort`, which orders `v0.3.9` after `v0.3.10`), read `git log <latest>..HEAD --oneline`, and bump by the strongest change present: a breaking change majors, any `feat` minors, otherwise patch. Below `1.0.0`, breaking changes bump the minor. State the proposed version, the tag it follows, and the commit types that drove it, then confirm before tagging. If no commits separate HEAD from the latest tag, stop: there is nothing to release.

**Draft the notes.** Read the commits and their diffs and group them by theme rather than listing them mechanically, matching the section structure of recent releases. Draft a title in the voice of existing release titles, preserving any prefix convention. Where recent releases carry a section on what was and was not verified, write one honestly: name what was actually exercised and what was only inspected. Show version, title, and full body, and let the user edit before anything is published.

**Close with the changelog range.** End the body with a compare link from the previous tag to the new one, matching the form recent releases use -- typically `**Full Changelog**: <compare-url>` as the last line. The previous tag is the one the version was inferred against, so the range covers exactly the commits described above it. Derive the base URL from `git remote get-url origin`, converting an SSH remote (`git@host:owner/repo.git`) to `https://host/owner/repo`, then build the path for the host:

| Host | Compare URL |
| --- | --- |
| GitHub | `<repo-url>/compare/<previous-tag>...<new-tag>` |
| GitLab | `<repo-url>/-/compare/<previous-tag>...<new-tag>` |

GitLab puts `/-/` before the route and GitHub does not, so a link built for the wrong forge 404s. On a first release there is no previous tag: omit the link rather than inventing a range.

**Publish on confirmation.** Create an annotated tag (`git tag -a <version> -m <title>`) when the repo's recent tags are annotated, a lightweight one when they are not; `git cat-file -t "$(git rev-parse <tag>)"` reports `tag` for annotated and `commit` for lightweight. That check is the one place the undereferenced form is wanted -- it is the tag object's own type that distinguishes the two.

Everywhere else, dereference. `git rev-parse <tag>` on an annotated tag returns the tag object, not the commit, and the two have different SHAs. Confirm the tag landed where intended with `git rev-parse <tag>^{commit}` against the resolved default branch's tip, and stop if they differ -- a local branch sitting behind its remote looks identical to an up-to-date one, and tagging there ships the previous release's tree under a new version. Report `<tag>^{commit}` as the released commit: the tag object's SHA appears nowhere in the log, so naming it sends the reader looking for a commit that does not exist.

Push the tag, always, before dispatching. The forges fail opposite ways when it is missing and the agents are configured so neither hides it: `gh` refuses the create outright, while `glab` would otherwise create the tag itself from a ref and mask the failed push. Then write the drafted body to a temp file outside the repo and dispatch `release-create` with the tag, title, and notes path -- plus the target branch on GitHub, which GitLab does not take. Ask for GitHub's `--generate-notes` only when the drafted body is meant to carry gh's commit list beneath it; GitLab has no equivalent. Display the release URL from the agent's report.

## Rules

Never publish without an explicit confirmation covering the final version, title, and body together. Never tag from a branch other than the resolved default branch, or from a dirty tree. Never invent a version that skips or reorders the sequence.

Never reuse an existing tag -- check with `git rev-parse <version>` first and stop if it resolves. On GitLab this is load-bearing rather than tidy: creating against a tag that already has a release overwrites its name and notes instead of failing.

Never claim in release notes that something was tested, verified, or exercised unless that actually happened in a way you can point to; describe inspected-only work as inspected. A release note is a public durable record, and an overstated one is worse than a terse one.

Never compose a remote command here -- an operation the agent's table does not cover is reported as unsupported, not worked around with a raw CLI call.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Version violation:** any tag that breaks the repo's existing format -- a missing or added `v` prefix, a truncated `MAJOR.MINOR.PATCH`, or a number that does not follow the latest tag -- must be corrected before tagging.

**Title violation:** any title that drops the repo's established prefix convention, or that restates the version number instead of describing the release, must be rewritten before publishing.

## User Input

$ARGUMENTS
