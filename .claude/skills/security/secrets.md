# Secrets hygiene

## Rules

1. Secrets live in the environment or a secret manager — never in code,
   never in git, never in client bundles, never in logs.
2. The repo carries `.env.example` with variable *names* and fake values;
   `.env*` is gitignored (this kit's hooks also block agents from reading it):

```bash
# .env.example — safe to commit; documents every variable and where it's set
DATABASE_URL=postgres://user:pass@localhost:5432/app   # Neon console → connection string
ANTHROPIC_API_KEY=sk-ant-xxxx                          # console.anthropic.com; rotate quarterly
STRIPE_WEBHOOK_SECRET=whsec_xxxx                       # Stripe dashboard → webhooks
```

3. One secret per purpose, least scope: a CI deploy token must not be able
   to read production data. Prefer short-lived / OIDC-issued credentials
   over long-lived PATs — e.g. GitHub Actions → cloud via OIDC:

```yaml
permissions:
  id-token: write        # OIDC federation — no stored cloud keys at all
  contents: read
```

4. Rotation must be boring: the `.env.example` comments above document where
   each secret comes from, so rotating takes minutes, not archaeology.

## Pre-commit guardrails

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.0
    hooks:
      - id: gitleaks
```

```toml
# .gitleaks.toml — extend the defaults with project-specific patterns
[extend]
useDefault = true
[[rules]]
id = "acme-internal-token"
regex = '''acme_tok_[A-Za-z0-9]{32}'''
```

Also enable GitHub **secret scanning + push protection** on the repo (org
settings) — it blocks the push before the leak exists.

Quick manual sweep before pushing anything agent-generated:

```bash
git diff --cached | grep -iE '(api[_-]?key|secret|token|passw|BEGIN (RSA|EC|OPENSSH))' \
  && echo "REVIEW THE ABOVE BEFORE PUSHING"
```

## If a secret leaks (commit, log, or chat)

1. **Rotate first, clean up second.** It was compromised the moment it
   touched git or an external service — deletion does not un-leak it
   (forks, mirrors, caches, scrapers watch public commits in seconds).
2. Revoke/rotate at the provider. Verify the old credential is actually dead
   (make a call with it; expect 401).
3. Then scrub history if required:
   ```bash
   git filter-repo --replace-text <(echo 'sk-ant-REDACTED==>REMOVED')
   ```
   force-push per your team's policy, and invalidate CI caches that may
   hold it.
4. Check provider audit logs for use of the leaked credential during the
   exposure window; treat any unknown use as an incident.
5. Add the leaked pattern to the scanner config (`.gitleaks.toml` above) so
   the same class can't recur.
