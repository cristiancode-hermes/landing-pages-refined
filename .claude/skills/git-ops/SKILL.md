---
name: git-ops
description: >-
  Git workflow — branches, commits, pull requests, rebases, and conflict
  resolution. Use when committing work, opening or updating a PR, rebasing,
  resolving merge conflicts, or untangling git state.
---

# Git Ops

References:

- [pr-workflow.md](pr-workflow.md) — branch → commits → PR that gets reviewed fast
- [rebase-conflicts.md](rebase-conflicts.md) — rebasing safely and resolving conflicts

## House rules (enforced by this kit's hooks where possible)

- Work on feature branches; `main` moves only via reviewed PRs.
- **No force-push to shared branches, ever.** `--force-with-lease` on your own
  feature branches only.
- Commits are atomic (one logical change) with imperative messages:
  `fix: reject expired sessions on refresh` — the body explains *why* when
  the diff can't.
- Never commit: secrets, `.env`, build output, `node_modules`, editor litter.
  Check `git status` before every commit; `git diff --cached` before every
  push.
- Don't rewrite history that others may have pulled; don't delete branches you
  didn't create this session.

## For agents

- Before starting: `git status` + `git log --oneline -5` — know the state you
  inherit. Never work on top of someone's uncommitted changes without saying so.
- Commit at meaningful checkpoints, not one giant end-of-session blob; each
  green state is a restore point.
- If git state looks wrong (detached HEAD, unexpected conflicts, missing
  commits), **stop and report** rather than "fixing" with resets — recovery
  beats improvisation, and `git reflog` sees all.
