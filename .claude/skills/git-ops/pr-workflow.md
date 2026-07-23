# PR workflow

## Branch → commits

```bash
git fetch origin main
git switch -c feat/order-cancellation origin/main   # always branch from fresh main
```

- Branch names: `feat/…`, `fix/…`, `chore/…`, `docs/…` + a 2-4 word slug.
- Commit early, commit atomic. A good message:

```
fix: reject refunds on orders older than 180 days

Stripe refuses refunds past 180 days and our retry queue was
hammering the API forever. Reject at validation time instead and
surface a support-contact message.

Refs #1234
```

Subject ≤ 72 chars, imperative, conventional prefix (`feat:`, `fix:`,
`refactor:`, `test:`, `chore:`); body explains **why** and the tradeoff,
not a prose rewrite of the diff.

- Useful mid-flight commands:

```bash
git add -p                       # stage hunks, keep commits atomic
git commit --fixup <sha>         # mark a fix for a previous commit…
git rebase -i --autosquash main  # …fold it in before opening the PR
git rebase origin/main           # keep fresh BEFORE review starts
```

After review starts, stop rebasing — push additive commits so reviewers see
what changed since their last pass; squash at merge.

## The PR itself

- **Small.** < ~400 changed lines reviews in hours; 2000 lines reviews
  never. Split by layer or by step (refactor-then-feature as two PRs).
- The description template that answers reviewers' real questions:

```markdown
## What
Reject refunds on orders older than 180 days at validation time.

## Why
Stripe hard-refuses these; our retry queue looped forever (INC-2311).

## How tested
- `npm test` — 342 passed, incl. new `refund-age.test.ts`
- Manually: POST /refunds against a 200-day-old sandbox order → 422 ✔

## Review focus
The date math in `refundEligibility()` — timezone edge on the 180th day.

## Screenshots
(UI changes only)
```

- PR title = squash-merge subject → same conventional format as commits.
- **Self-review the "Files changed" tab before requesting review** — you'll
  catch the debug print, the stray file, the TODO. Every reviewer-found nit
  you could have caught costs a round trip.

## Review etiquette (both directions)

- Respond to every comment (fix, or explain why not) — silent-fix-and-push
  makes reviewers re-read everything.
- Re-request review after addressing; don't merge over unresolved threads.
- Reviewing others: comment on the code, not the person; distinguish
  blocking issues from `nit:` preferences; approve at *good enough*, not
  perfect:

```markdown
blocking: this loses the error cause — wrap with `throw new X(..., {cause: err})`
nit: could be a single `flatMap`, fine either way
```

## Merging

```bash
# ensure green + current before merge
git fetch origin main && git rebase origin/main && git push --force-with-lease
```

- Squash-merge feature branches (one clean commit on main) unless commits
  are deliberately curated.
- Delete the branch after merge. A merged PR is closed history — follow-ups
  get a **fresh branch from main**, never new commits on the merged branch.
