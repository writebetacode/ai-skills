---
name: remote-release
description: Tag the default branch and publish a release on GitHub or GitLab, inferring the version from commit history and drafting notes in the repo's established voice. Use when cutting, shipping, or publishing a release, when tagging a new version, or when working out what the next version number should be. This is the post-merge step, run on the default branch rather than on a feature branch whose PR is still open.
argument-hint: "[version]"
allowed-tools: "Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh release list:*), Bash(gh release view:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab release list:*), Bash(glab release view:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git remote get-url:*), Bash(git tag -l:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git status --short:*)"
---

# Remote Release

One skill for both forges. What follows is host-agnostic; the commands live in the host's reference file.

## Host

Resolve the forge from the `origin` remote, then read `${CLAUDE_SKILL_DIR}/github.md` for GitHub or `${CLAUDE_SKILL_DIR}/gitlab.md` for GitLab before running anything -- it carries the command for every operation named below. Where that path arrives unexpanded the runtime is not Claude Code: read the file of that name from this skill's own directory instead -- `~/.gemini/skills/remote-release/<file>.md` under Gemini CLI -- rather than treating the reference as missing. Where a self-hosted URL settles nothing, read both files and run each CLI's `repo-id`, taking the one that resolves; if both do or neither does, ask the user.

A missing CLI stops the run rather than being routed around: tell the user which one to install, with the URL from the reference file, never substitute the other forge's CLI or a raw `curl` against the API, and never tag or push on the way to a release that cannot then be published.

Pass the release notes as a file path -- writing them to a temp file and letting the CLI read it is what keeps a body byte-exact and out of reach of shell quoting.

## Workflow

Run `auth`; stop on failure. Resolve the default branch via `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`), falling back to `git remote show origin` parsed for `HEAD branch:`; never assume `main`. Check it out, `git pull`, and confirm `git status --short` is empty, naming what is in the way if it is not.

**Establish conventions from the repo, never from this file.** Read existing tags with `git tag -l --sort=-v:refname` and recent releases with `release-list` and `release-view`. Match what you find: tag format, title prefix, body structure, whether tags are annotated. The patterns below describe the common case; the repo's actual history always wins.

**Resolve the version.** An explicit version in the arguments wins outright -- normalize its `v` prefix to match existing tags. Otherwise take the latest tag by `--sort=-v:refname` (never plain `sort`, which orders `v0.3.9` after `v0.3.10`), read `git log <latest>..HEAD --oneline`, and bump by the strongest change present: a breaking change majors, any `feat` minors, otherwise patch. Below `1.0.0`, breaking changes bump the minor. State the proposed version, the tag it follows, and the commit types that drove it, then confirm before tagging. If no commits separate HEAD from the latest tag, stop: there is nothing to release.

**Draft the notes.** Read the commits and their diffs and group them by theme rather than listing them mechanically, matching the section structure of recent releases. Draft a title in the voice of existing release titles, preserving any prefix convention. Where recent releases carry a section on what was and was not verified, write one honestly: name what was actually exercised and what was only inspected. Show version, title, and full body, and let the user edit.

Length follows the same rule as structure -- the repo's own releases set it, and are matched even where they run long. Where there is nothing to match, on a first release or against past notes too inconsistent to read a convention from, the default is one sentence of context, then one line per grouped item, plus the verification section where it applies and the changelog link below.

**Close with the changelog range.** End the body with a compare link from the previous tag to the new one, matching the form recent releases use -- typically `**Full Changelog**: <compare-url>` as the last line. The previous tag is the one the version was inferred against, so the range covers exactly the commits described above it. Derive the base URL from `git remote get-url origin`, converting an SSH remote (`git@host:owner/repo.git`) to `https://host/owner/repo`, then build the path for the host:

| Host | Compare URL |
| --- | --- |
| GitHub | `<repo-url>/compare/<previous-tag>...<new-tag>` |
| GitLab | `<repo-url>/-/compare/<previous-tag>...<new-tag>` |

GitLab puts `/-/` before the route and GitHub does not, so a link built for the wrong forge 404s. On a first release there is no previous tag: omit the link rather than inventing a range.

**Publish on confirmation.** Create an annotated tag (`git tag -a <version> -m <title>`) when the repo's recent tags are annotated, a lightweight one when they are not; `git cat-file -t "$(git rev-parse <tag>)"` reports `tag` for annotated and `commit` for lightweight -- the one place the undereferenced form is wanted, since it inspects the tag object itself.

Everywhere else dereference: on an annotated tag `git rev-parse <tag>` returns that object, so compare and report `<tag>^{commit}`. Confirm it equals the resolved default branch's tip before publishing, and stop if it does not -- a branch behind its remote looks identical to one up to date, and tagging there ships the last release's tree under a new version.

Push the tag, always, before creating the release. The forges fail opposite ways when it is missing and the reference files are written so neither hides it: `gh` refuses the create outright, while `glab` would otherwise create the tag itself from a ref and mask the failed push. Then write the drafted body to a temp file outside the repo and run `release-create` with the tag, title, and notes path -- plus the target branch on GitHub, which GitLab does not take. Pass GitHub's `--generate-notes` only when the drafted body is meant to carry gh's commit list beneath it; GitLab has no equivalent. Display the release URL the CLI returns.

## Rules

Never publish without an explicit confirmation covering the final version, title, and body together. Never tag from a branch other than the resolved default branch, or from a dirty tree. Never invent a version that skips or reorders the sequence.

Never reuse an existing tag -- check with `git rev-parse --verify <version>` first and stop if it resolves. Keep `--verify`: the bare form prints the tag name back on a miss and exits non-zero, which reads like a hit to anyone not checking the exit code. On GitLab this is load-bearing rather than tidy: creating against a tag that already has a release overwrites its name and notes instead of failing.

Never claim in release notes that something was tested, verified, or exercised unless that actually happened in a way you can point to; describe inspected-only work as inspected. A release note is a public durable record, and an overstated one is worse than a terse one.

Never compose a remote command from memory -- every one comes from the host's reference file, and an operation it does not cover is reported as unsupported rather than improvised.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Version violation:** any tag that breaks the repo's existing format -- a missing or added `v` prefix, a truncated `MAJOR.MINOR.PATCH`, or a number that does not follow the latest tag -- must be corrected before tagging. Against a latest tag of `v1.4.2`, `1.4.3` drops the prefix, `v1.5` truncates, and `v1.6.0` skips the sequence; `v1.4.3` and `v1.5.0` are acceptable.

**Title violation:** any title that drops the repo's established prefix convention, or that restates the version number instead of describing the release, must be rewritten before publishing. Where recent releases read `Release v1.4.2 -- <description>`, both `v1.4.3` and `Release v1.4.3` are violations, naming the version and describing nothing; `Release v1.4.3 -- narrower glab permissions and a follow-up review mode` is acceptable.

## User Input

$ARGUMENTS
