# Rebases & conflict resolution

## Rebase safely

```bash
git fetch origin main
git rebase origin/main            # replay your branch on fresh main
# …resolve any conflicts commit by commit…
git push --force-with-lease       # feature branch only, NEVER shared branches
```

- `--force-with-lease` refuses to clobber commits you haven't seen; plain
  `-f` is banned (and blocked by this kit's pre-tool-use hook for
  main/master).
- Never rebase commits that exist on a shared branch — rewriting published
  history forks every teammate's clone.
- Long-lived branch far behind main? Rebase in stages or merge main in — a
  60-conflict mega-rebase invites mistakes.
- Escape hatches:

```bash
git rebase --abort            # back to the pre-rebase state
git reflog                    # finds ANY "lost" commit — nothing is gone
git checkout -b rescue <sha>  # resurrect from the reflog
```

## Resolving conflicts — a procedure, not vibes

1. `git status` lists conflicted files; take them one at a time.
2. Understand **both intents** before touching the markers:

```bash
git log --merge --oneline -- src/pricing.ts   # the competing commits
git show REBASE_HEAD -- src/pricing.ts        # "theirs": your commit being replayed
git show HEAD -- src/pricing.ts               # "ours": the branch you're rebasing onto
```

**During a rebase the markers invert vs a merge**: `<<<<<<< HEAD` is the
branch you're rebasing **onto** (main), `>>>>>>>` is **your** commit being
replayed. Read the commits, not just the labels.

3. The right resolution is usually **both changes combined**:

```ts
<<<<<<< HEAD
const total = subtotal + shipping(order);          // main added shipping
=======
const total = applyDiscount(subtotal, coupon);     // you added discounts
>>>>>>> feat: coupon support

// ✔ resolution honors BOTH intents — not "keep mine":
const total = applyDiscount(subtotal, coupon) + shipping(order);
```

4. After each file: no markers left, run that file's tests, `git add`.

```bash
rg -n '^(<{7}|={7}|>{7})' && echo "MARKERS REMAIN"   # sweep before continuing
git rebase --continue
```

5. At the end, run the **full** suite — a conflict can resolve cleanly
   text-wise and still be semantically wrong (the classic: both sides
   renamed the same function differently, no textual overlap, broken build).

## When it goes sideways

```bash
git config rerere.enabled true    # same conflicts recurring every rebase?
                                  # rerere replays your recorded resolutions

git checkout --conflict=merge src/pricing.ts   # restore markers after a bad resolve

# committed a mess? don't pile fixes on top:
git reflog                        # find the last good state
git reset --hard <good-sha>       # your own branch only — then redo cleanly
```

- Binary/lockfile conflicts: regenerate instead of merging —
  `git checkout --theirs package-lock.json && npm install` then verify.
- If git state looks *wrong* (detached HEAD, missing commits you're sure
  existed): stop, `git reflog`, and report before "fixing" with resets —
  recovery beats improvisation.
