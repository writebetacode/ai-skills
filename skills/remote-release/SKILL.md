---
name: remote-release
description: Tag the default branch and publish a release on GitHub or GitLab, inferring the version from commit history and drafting notes in the repo's established voice. Use when cutting, shipping, or publishing a release, when tagging a new version, or when working out what the next version number should be. This is the post-merge step, run on the default branch rather than on a feature branch whose PR is still open.
argument-hint: "[version]"
allowed-tools: "Bash(gh auth status:*), Bash(gh repo view:*), Bash(gh release list:*), Bash(gh release view:*), Bash(glab auth status:*), Bash(glab repo view:*), Bash(glab release list:*), Bash(glab release view:*), Bash(git symbolic-ref:*), Bash(git remote show:*), Bash(git remote get-url:*), Bash(git tag -l:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git status --short:*)"
---

# Remote Release

## Host

Resolve the forge from the `origin` remote, then read `${CLAUDE_SKILL_DIR}/github.md` or `${CLAUDE_SKILL_DIR}/gitlab.md` before running anything; it has the command for every operation named below. If the path arrives unexpanded, you're not in Claude Code: read the same file from this skill's own installed directory instead (`~/.gemini/skills/remote-release/<file>.md` under Gemini CLI) rather than treating the reference as missing. If a self-hosted URL doesn't settle the forge, read both files and use whichever CLI's `repo-id` resolves; if both or neither do, ask.

If the CLI is missing, stop and tell the user which one to install, with the URL from the reference file. Never switch to the other forge's CLI or raw `curl`, and never tag or push toward a release that can't then be published.

## Workflow

1. **Prepare.** Run `auth`; stop on failure. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`), falling back to `HEAD branch:` from `git remote show origin`; never assume `main`. Check it out, `git pull`, and confirm `git status --short` is empty, naming what's in the way if not.
2. **Read the conventions from the repo, never from this file.** Tags via `git tag -l --sort=-v:refname`, recent releases via `release-list` and `release-view`. Match tag format, title prefix, body structure, and whether tags are annotated.
3. **Resolve the version.** A version in the arguments wins, with its `v` prefix matched to existing tags. Otherwise take the latest tag by `--sort=-v:refname` (plain `sort` puts `v0.3.9` after `v0.3.10`), read `git log <latest>..HEAD --oneline`, and bump by the strongest change: breaking is major, any `feat` is minor, else patch; below `1.0.0`, breaking bumps minor. If nothing is past the latest tag, stop: there's nothing to release. State the version, the tag it follows, and the commit types behind it, and confirm before tagging.
4. **Draft the notes.** Group commits and diffs by theme, not one line per commit, in the section structure of recent releases, and write the title in their voice with any prefix kept. Recent releases also set the length, even when long. With nothing to match (first release, or inconsistent history), write one sentence of context and one line per grouped item, plus the verification section where it applies and the changelog link. If recent releases have a verification section, write one honestly: what was actually exercised versus only inspected. Show version, title, and full body for edits.
5. **End with the changelog range** in the form recent releases use, usually a final `**Full Changelog**: <compare-url>` line, starting from the tag the version was inferred from. Base URL from `git remote get-url origin`, SSH (`git@host:owner/repo.git`) converted to `https://host/owner/repo`. On a first release, leave it out rather than invent a range.

   | Host | Compare URL |
   | --- | --- |
   | GitHub | `<repo-url>/compare/<previous-tag>...<new-tag>` |
   | GitLab | `<repo-url>/-/compare/<previous-tag>...<new-tag>` |

6. **Tag.** Annotated (`git tag -a <version> -m <title>`) if recent tags are, lightweight otherwise; `git cat-file -t "$(git rev-parse <tag>)"` reports `tag` or `commit`, the one place to use the undereferenced form. Everywhere else use `<tag>^{commit}`, since `git rev-parse` on an annotated tag returns the tag object. Confirm `<tag>^{commit}` equals the default branch's tip and stop if not: a branch behind its remote looks up to date, and tagging there ships the last release's tree under a new version.
7. **Publish.** Always push the tag first: `gh` refuses a release for a missing tag, but `glab` would create the tag itself and hide the failed push. Write the body to a temp file outside the repo (never retype notes into a command) and run `release-create` with tag, title, and notes path, plus the target branch on GitHub. Add `--generate-notes` (GitHub only) only if the body should carry gh's commit list under it. Show the release URL.

## Rules

- Never tag or publish without one explicit confirmation covering the final version, title, and body together.
- Never tag from anything but the resolved default branch, or from a dirty tree.
- Never pick a version that skips or reorders the sequence.
- Never reuse a tag: check `git rev-parse --verify <version>` and stop if it resolves. Keep `--verify`, since without it a miss prints the name back and only the exit code tells you. On GitLab, creating against a tag that has a release overwrites its name and notes instead of failing.
- Never claim in notes that anything was tested, verified, or exercised unless you can point to it happening; describe inspected-only work as inspected. Release notes are a public, lasting record.
- Never write a remote command from memory; anything the reference file doesn't cover is unsupported.
- Restrict generated output -- commits, PRs, issues, and files you write -- to ASCII; never include AI attribution or "Co-Authored-By" lines.

**Version violation:** a tag breaking the repo's format: a missing or extra `v`, a truncated `MAJOR.MINOR.PATCH`, or a number not following the latest tag. After `v1.4.2`, `1.4.3`, `v1.5`, and `v1.6.0` are violations; `v1.4.3` and `v1.5.0` are acceptable.

**Title violation:** a title that drops the repo's prefix convention, or states the version instead of describing the release. Where recent titles read `Release v1.4.2 -- <description>`, `v1.4.3` and `Release v1.4.3` are violations; `Release v1.4.3 -- narrower glab permissions and a follow-up review mode` is acceptable.

## User Input

$ARGUMENTS
