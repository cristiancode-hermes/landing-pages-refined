# Security audit checklist

Work through the sections that match the diff. For each finding report:
location (`file:line`), the concrete attack, severity, and the minimal fix.

## Injection

```python
# ☠ SQL built from user input
cur.execute(f"SELECT * FROM users WHERE email = '{email}'")
# ✔ parameterized — the only acceptable form
cur.execute("SELECT * FROM users WHERE email = %s", (email,))
```

```python
# ☠ shell with user data
subprocess.run(f"convert {filename} out.png", shell=True)
# ✔ arg array, no shell
subprocess.run(["convert", filename, "out.png"], shell=False)
```

```python
# ☠ path traversal: filename = "../../etc/passwd"
open(os.path.join(UPLOAD_DIR, filename))
# ✔ normalize, then verify the prefix
path = os.path.realpath(os.path.join(UPLOAD_DIR, filename))
if not path.startswith(os.path.realpath(UPLOAD_DIR) + os.sep):
    raise Forbidden()
```

- [ ] SQL/NoSQL built by concatenation or f-strings anywhere
- [ ] `subprocess`/`exec`/`eval`/`os.system` receiving anything user-derived
- [ ] Unquoted shell variables in scripts (`$FILE` vs `"$FILE"`)
- [ ] HTML rendered unescaped (`dangerouslySetInnerHTML`, `| safe`, `v-html`)
      fed by user data → XSS
- [ ] Deserialization of untrusted data (`pickle`, `yaml.load` without
      `SafeLoader`, Java native serialization)

## AuthN / AuthZ

```ts
// ☠ IDOR — the most common real-world bug: authenticated ≠ authorized
app.get("/orders/:id", auth, async (req, res) => {
  res.json(await orders.findById(req.params.id));
});
// ✔ ownership enforced in the query itself
app.get("/orders/:id", auth, async (req, res) => {
  const order = await orders.findOne({ id: req.params.id, userId: req.user.id });
  if (!order) return res.sendStatus(404);   // 404, not 403 — don't confirm existence
  res.json(order);
});
```

- [ ] Every state-changing endpoint checks *ownership/role*, not just a
      valid session
- [ ] Session cookies: `HttpOnly`, `Secure`, `SameSite=Lax|Strict`;
      session id rotated on login
- [ ] CSRF protection on all cookie-authenticated mutations
- [ ] Passwords: bcrypt/argon2 with per-user salt (never MD5/SHA-x alone);
      token comparisons constant-time (`hmac.compare_digest`, not `==`)
- [ ] Rate limiting on login/reset/OTP endpoints
- [ ] JWT: algorithm pinned (reject `none`), `exp` enforced, `iss`/`aud`
      verified, secret ≥ 256 bits

## Data & transport

```python
# ☠ SSRF: user-supplied URL fetched server-side
requests.get(request.args["url"])
# ✔ allowlist hosts + block internal ranges after DNS resolution
host = urlparse(url).hostname
ip = ipaddress.ip_address(socket.getaddrinfo(host, None)[0][4][0])
if host not in ALLOWED_HOSTS or ip.is_private or ip.is_link_local or ip.is_loopback:
    raise Forbidden()
```

- [ ] Secrets in code, config, logs, error messages, or client bundles
- [ ] PII logged or sent to third parties without need
- [ ] TLS verification disabled anywhere (`verify=False`,
      `rejectUnauthorized: false`, `curl -k`)
- [ ] User uploads: extension + magic-bytes validated, stored outside the
      web root, served with `Content-Disposition` + a separate domain/CDN
- [ ] Error responses leak stack traces, versions, or query text

## Dependencies & CI

- [ ] Lockfile present; installs reproducible
- [ ] `npm audit` / `pip-audit` / `cargo audit` clean of criticals
- [ ] GitHub Actions: no `pull_request_target` with checkout of PR code;
      secrets unavailable to fork PRs; third-party actions pinned to SHAs:
      ```yaml
      - uses: actions/checkout@8f4b7f84864484a7bf31766abe9204da3cbe65b3  # v4, pinned
      ```
- [ ] CI tokens least-privilege (`permissions:` block per workflow, not
      default write-all)
