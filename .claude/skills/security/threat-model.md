# Lightweight threat modeling

Run this before building a feature that touches trust boundaries (new
endpoint, upload, integration, auth change). Twenty minutes here beats a CVE
later.

## 1. Draw the data flow

List: entry points (who can send data in), assets (what's worth stealing or
corrupting), trust boundaries (network edges, user↔service, service↔service,
human↔agent). A bullet list is fine; a diagram is better.

Worked example — "user-uploaded CSV import":

```
Entry points:  POST /imports (auth'd users), the CSV parser, the row-apply job
Assets:        other tenants' data, DB integrity, S3 bucket, worker credentials
Boundaries:    browser→API (untrusted), API→S3, worker→DB (privileged)
```

## 2. STRIDE per boundary

| Threat | Question | CSV-import example |
|---|---|---|
| **S**poofing | Can someone pretend to be another user/service? | forged pre-signed S3 URLs? |
| **T**ampering | Can data be modified in transit/at rest? | CSV edited between scan and apply? |
| **R**epudiation | Could a user deny an action we don't log? | who imported the bad rows? |
| **I**nfo disclosure | What leaks if this is compromised/verbose? | error echoes other tenants' row data? |
| **D**oS | 1000× load or a 2GB payload? | 10M-row CSV, zip bomb, formula bomb |
| **E**levation | Low-privilege caller → high-privilege path? | CSV cells hitting `eval`-ish parsing? |

## 3. Rank and decide

For each threat: likelihood × impact → **mitigate** (control), **accept**
(write down why), or **eliminate** (remove the surface). Record decisions
where reviewers will see them:

```markdown
<!-- PR description or docs/adr/0007-csv-import-threats.md -->
## Threat decisions
- 2GB uploads (DoS, likely/medium) → MITIGATE: 50MB limit + streaming parse
- CSV formula injection (=cmd|...) → MITIGATE: prefix-escape on export
- Malicious pre-signed URL reuse   → MITIGATE: 5-min expiry, one-time key
- Repudiation of imports           → MITIGATE: audit row (user, file hash, ts)
- Zip bombs                        → ELIMINATE: reject archives entirely
- Insider DB access                → ACCEPT: covered by org-level controls
```

An unwritten threat model doesn't exist.

## Agent-specific boundaries

When the system includes an LLM agent, add these boundaries — the mitigation
pattern is constant: least-privilege tools, human gates on irreversible
actions, and treating all retrieved content as data:

- **User prompt → agent**: direct injection ("ignore previous instructions").
- **Retrieved/web/PR content → agent**: *indirect* injection — the page or
  comment the agent reads contains instructions. Wrap external content in
  markers and instruct the model it is data, e.g.
  `<external>...</external>`; act on redirection attempts by stopping and
  surfacing to the user.
- **Agent → tools**: excessive permissions. A read-mostly agent must not
  hold write credentials "just in case" (see this kit's `settings.json`
  deny-list approach).
- **Tool output → agent**: poisoned results (a fetched file containing
  instructions). Same envelope treatment as retrieved content.
