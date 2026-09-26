---
name: remote-release
description: Tag the default branch and publish a release on GitHub or GitLab, inferring the version from commit history and drafting notes in the repo's established voice. Use when cutting, shipping, or publishing a release, when tagging a new version, or when working out what the next version number should be. This is the post-merge step, run on the default branch rather than on a feature branch whose PR is still open.
argument-hint: "[version]"
allowed-tools: "Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh release list:*), Bash(gh release view:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab release list:*), Bash(glab release view:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git remote get-url:*), Bash(git tag -l:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git status --short:*)"
---

# Remote Release

## Host

Resolve the forge from the `origin` remote. Before running anything, read `${CLAUDE_SKILL_DIR}/github.md` for GitHub or `${CLAUDE_SKILL_DIR}/gitlab.md` for GitLab. It has the command for every operation named below. If that path arrives unexpanded, you are not in Claude Code: read the same file from the skill's installed directory instead (`~/.gemini/skills/remote-release/<file>.md` under Gemini CLI). If a self-hosted URL doesn't settle the forge, read both files and run each CLI's `repo-id`, then use the one that resolves. If both or neither resolve, ask the user.

If the CLI is missing, stop and tell the user which one to install, using the URL in the reference file. Never switch to the other forge's CLI or a raw `curl` against the API, and never tag or push toward a release that can't then be published.

## Workflow

Run `auth` and stop if it fails. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the leading `origin/`). If that fails, parse `HEAD branch:` from `git remote show origin`. Never assume `main`. Check it out, `git pull`, and confirm `git status --short` is empty. If it isn't, name what is in the way.

**Take the conventions from the repo, never from this file.** Read the tags with `git tag -l --sort=-v:refname` and recent releases with `release-list` and `release-view`. Match the tag format, title prefix, body structure, and whether tags are annotated.

**Resolve the version.** A version in the arguments wins; adjust its `v` prefix to match existing tags. Otherwise take the latest tag by `--sort=-v:refname` (plain `sort` puts `v0.3.9` after `v0.3.10`), read `git log <latest>..HEAD --oneline`, and bump by the strongest change: breaking is major, any `feat` is minor, anything else is patch. Below `1.0.0`, a breaking change bumps the minor. State the proposed version, the tag it follows, and the commit types behind it, and confirm before tagging. If there are no commits since the latest tag, stop: there is nothing to release.

**Draft the notes.** Read the commits and their diffs. Group them by theme, not one line per commit, using the section structure of recent releases. Write the title in the voice of existing titles, keeping any prefix. If recent releases have a section on what was verified, write one honestly: say what was actually exercised and what was only inspected. Recent releases also set the length, even when they run long. With nothing to match (a first release, or past notes too inconsistent to read), write one sentence of context, then one line per grouped item, plus the verification section where it applies and the changelog link. Show the version, title, and full body, and let the user edit them.

**End with the changelog range**, in the form recent releases use, usually `**Full Changelog**: <compare-url>` as the last line. The range starts at the tag the version was inferred from. Build the base URL from `git remote get-url origin`, converting SSH (`git@host:owner/repo.git`) to `https://host/owner/repo`:

| Host | Compare URL |
| --- | --- |
| GitHub | `<repo-url>/compare/<previous-tag>...<new-tag>` |
| GitLab | `<repo-url>/-/compare/<previous-tag>...<new-tag>` |

Only GitLab has the `/-/`, so a link built for the wrong forge 404s. On a first release there is no previous tag, so leave the link out rather than inventing a range.

**Publish on confirmation.** Create an annotated tag (`git tag -a <version> -m <title>`) if recent tags are annotated, otherwise a lightweight one. `git cat-file -t "$(git rev-parse <tag>)"` reports `tag` for annotated and `commit` for lightweight. That is the one place to use the undereferenced form. Everywhere else, use `<tag>^{commit}`, because `git rev-parse <tag>` on an annotated tag returns the tag object. Confirm `<tag>^{commit}` equals the default branch's tip before publishing, and stop if it doesn't: a branch behind its remote looks the same as an up-to-date one, and tagging there ships the last release's tree under a new version.

Always push the tag before creating the release. `gh` refuses to create a release for a missing tag, but `glab` would create the tag itself and hide the failed push. Write the body to a temp file outside the repo and run `release-create` with the tag, title, and notes path (never retype the notes into a command, so they arrive byte-exact), plus the target branch on GitHub only. Pass `--generate-notes` (GitHub only) only if the body is meant to carry gh's commit list under it. Show the release URL the CLI returns.

## Rules

Never publish without one explicit confirmation that covers the final version, title, and body together. Never tag from any branch other than the resolved default branch, and never from a dirty tree. Never pick a version that skips or reorders the sequence.

Never reuse a tag. Check with `git rev-parse --verify <version>` and stop if it resolves. Keep `--verify`: without it, a miss prints the name back and exits non-zero, which looks like a hit if you don't check the exit code. On GitLab, creating against a tag that already has a release overwrites that release's name and notes instead of failing.

Never claim in release notes that anything was tested, verified, or exercised unless you can point to it actually happening. Describe inspected-only work as inspected. Release notes are a public, lasting record.

Never write a remote command from memory. Every command comes from the host's reference file, and an operation the file doesn't cover is reported as unsupported.

Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Version violation:** a tag that breaks the repo's format, such as a missing or extra `v`, a truncated `MAJOR.MINOR.PATCH`, or a number that doesn't follow the latest tag. After `v1.4.2`, `1.4.3`, `v1.5`, and `v1.6.0` are violations. `v1.4.3` and `v1.5.0` are acceptable.

**Title violation:** a title that drops the repo's prefix convention, or that just states the version instead of describing the release. Where recent titles read `Release v1.4.2 -- <description>`, both `v1.4.3` and `Release v1.4.3` are violations. `Release v1.4.3 -- narrower glab permissions and a follow-up review mode` is acceptable.

## User Input

$ARGUMENTS
