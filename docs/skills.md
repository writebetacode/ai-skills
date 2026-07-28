# Skills

Skills live in `skills/` and are shared by both Claude Code and Gemini CLI.

Every git-facing skill resolves the repo's default branch from `origin/HEAD` rather than assuming `main`, so they behave correctly on repos that default to `develop`, `master`, or `trunk`. None of them pin a model — each runs on whatever model your session is already using, so invoking a skill never silently changes tiers or costs. Agents are the opposite case and do pin one; see [Agents](agents.md).

## Git, GitHub & GitLab

| Command | Description |
|---|---|
| `/commit` | Stage-aware conventional commits — commits exactly what is staged, immediately |
| `/pr` | Create or update GitHub pull requests with structured descriptions |
| `/mr` | Create or update GitLab merge requests with the same structured description, via `glab` |
| `/restack` | Rebase open branches onto the latest default branch, whether their base was squash-merged or the default branch simply moved ahead |
| `/prune-branches` | Delete local branches whose changes already landed in the default branch, including squash-merged branches `git branch -d` refuses as unmerged |
| `/gh-issue` | Create consistently-formatted GitHub issues with type, priority, and optional context sections |
| `/gh-release` | Tag the default branch and publish a GitHub release, inferring the version from commit history and drafting notes in the repo's established voice |

`/pr` and `/mr` share a body template with its own rules — see [PR/MR body template](pr-mr-template.md).

## Software development workflow

The SDLC commands are documented separately: see [SDLC workflow](sdlc.md).

| Command | Phase | Description |
|---|---|---|
| `/sdlc-design` | 1 — Design | Turn an idea into specs, plans, tasks, and ADRs through strict one-at-a-time questioning routed to a persistent architect agent |
| `/sdlc-implement` | 2 — Implement | Execute tasks with persistent tester and coder agents, batched TDD loop, and third-party spec-vs-code validation |
| `/sdlc-complete` | 3 — Complete | Archive a finished project to `plans/complete/YYYYMMDD-<slug>/` and clean up its local branches |
