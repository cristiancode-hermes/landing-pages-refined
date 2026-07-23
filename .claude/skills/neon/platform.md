# Neon platform — branching, compute, connections

## Branching (the killer feature — use it everywhere)

A branch is an instant copy-on-write copy of the database (schema + data)
with its own compute. Treat databases like git:

```bash
neon branches create --name preview/pr-123 --parent main
neon connection-string preview/pr-123
neon branches delete preview/pr-123

# migration rehearsal: free, instant, zero risk to prod
neon branches create --name rehearse-0042 --parent main
DATABASE_URL=$(neon connection-string rehearse-0042) npm run db:migrate
DATABASE_URL=$(neon connection-string rehearse-0042) npm run test:integration
neon branches delete rehearse-0042
```

Per-PR preview databases in GitHub Actions:

```yaml
# .github/workflows/preview.yml
on: pull_request
jobs:
  preview-db:
    runs-on: ubuntu-latest
    steps:
      - uses: neondatabase/create-branch-action@v5
        id: branch
        with:
          project_id: ${{ vars.NEON_PROJECT_ID }}
          branch_name: preview/pr-${{ github.event.number }}
          api_key: ${{ secrets.NEON_API_KEY }}
      - run: npm run db:migrate && npm run test:e2e
        env:
          DATABASE_URL: ${{ steps.branch.outputs.db_url_pooled }}
# companion delete-branch-action runs on PR close
```

- **Test isolation**: one branch per e2e suite (or per worker) instead of
  docker-compose Postgres — real data shape, zero cleanup.
- **Instant restore**: branch from a point in time
  (`neon branches create --parent main@2026-07-04T09:00:00Z`) — "5 minutes
  before the bad deploy" — verify, then promote/swap.

## Compute & scaling

- **Autoscaling** moves CPU/RAM with load between a min/max you set;
  **scale-to-zero** suspends idle computes.
- Dev/preview branches: scale-to-zero ON (they're free while idle).
  Latency-sensitive production: set min compute > 0 instead of fighting
  cold starts with keep-alive hacks.
- Read replicas are read-only computes on the same storage — no replication
  lag management; route heavy analytics there.

## Connections — pick the right mode

| Context | Use |
|---|---|
| Serverless/edge functions | `@neondatabase/serverless` (HTTP/WebSocket) or Data API |
| Long-lived server (Nest, etc.) | **pooled** string (`-pooler` host, PgBouncer) |
| Migrations, `LISTEN/NOTIFY`, advisory locks | **direct** (unpooled) string |
| Frontend without a backend | Data API + Neon Auth JWT (data-api.md) |

```ts
// serverless driver: per-query HTTP (cheap), or transactions when needed
import { neon } from '@neondatabase/serverless';
const sql = neon(process.env.DATABASE_URL!);

const [user] = await sql`SELECT * FROM users WHERE id = ${id}`;

await sql.transaction([                       // batched atomic writes
  sql`UPDATE accounts SET balance = balance - ${amt} WHERE id = ${from}`,
  sql`UPDATE accounts SET balance = balance + ${amt} WHERE id = ${to}`,
]);
```

```ts
// Nest/TypeORM/Prisma on a server: pooled for the app…
DATABASE_URL=postgres://user:pw@ep-xxx-pooler.eu-central-1.aws.neon.tech/db
// …direct only for migrations (PgBouncer transaction mode breaks
// prepared statements and session SET):
DIRECT_URL=postgres://user:pw@ep-xxx.eu-central-1.aws.neon.tech/db
```

## Agent & tooling integration

Add Neon's MCP server to `.mcp.json` when a project builds on Neon — agents
can then create branches, run SQL, and inspect schemas conversationally:

```json
{
  "mcpServers": {
    "neon": {
      "command": "npx",
      "args": ["-y", "@neondatabase/mcp-server-neon", "start"],
      "env": { "NEON_API_KEY": "${NEON_API_KEY}" }
    }
  }
}
```

- `neonctl` covers everything in CI; API keys are secrets (security track
  rules apply).
- Extensions beyond pgvector (PostGIS, pg_cron, timescale-style workloads):
  check Neon's extensions list before assuming something's missing.
