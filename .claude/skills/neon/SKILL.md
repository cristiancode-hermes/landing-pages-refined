---
name: neon
description: >-
  Neon serverless Postgres — Data API (PostgREST-compatible, backend-optional
  apps), Neon Auth with RLS, pgvector for embeddings/similarity search,
  branching, autoscaling, and the serverless driver. Use when building on
  Neon, designing a no-dedicated-backend architecture, adding vector search,
  or wiring database branches into CI.
---

# Neon (serverless Postgres)

References:

- [data-api.md](data-api.md) — the PostgREST-compatible Data API; apps without a dedicated backend
- [auth-rls.md](auth-rls.md) — Neon Auth, JWTs, and Row-Level Security as the authorization layer
- [pgvector.md](pgvector.md) — embeddings, HNSW indexes, similarity search
- [platform.md](platform.md) — branching, autoscaling/scale-to-zero, connections, MCP

## Mental model

Neon is Postgres with compute/storage separated: compute autoscales and can
scale to zero; storage supports **instant copy-on-write branches** (git-like).
Everything that works on Postgres works here — plus:

- **Data API**: query tables over HTTPS (PostgREST protocol) straight from the
  frontend — no backend service required when RLS carries the authorization.
- **Neon Auth**: managed users/sessions stored in your database, issuing JWTs
  that RLS policies consume (or bring your own provider via JWKS).
- **pgvector on every plan**: the vector database is just another extension.
- **Branches**: per-PR/per-test isolated database copies in seconds.

## Ground rules

1. **RLS discipline**: the moment the Data API is enabled, RLS is your entire
   authorization layer — every exposed table needs explicit policies *before*
   it holds real data. No policy = no access (default deny), and test policies
   like code (see auth-rls.md).
2. Schema changes ride migrations (drizzle-kit, Prisma migrate, plain SQL) —
   never hand-edited console changes on the primary branch. Test migrations on
   a branch first; it's free.
3. Connections: serverless/edge runtimes use the HTTP driver
   (`@neondatabase/serverless`) or the Data API; long-lived servers use the
   pooled connection string (PgBouncer, `-pooler` host). Direct (unpooled)
   connections only for migrations and session-level features.
4. Scale-to-zero means **cold starts**: the first query after idle takes
   longer. Keep it enabled for dev/preview branches; for latency-sensitive
   production, configure a minimum compute instead of hacking keep-alive pings.
