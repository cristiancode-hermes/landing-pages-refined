# Neon Data API — apps without a dedicated backend

The Data API exposes your database over HTTPS using the **PostgREST
protocol** (re-implemented in Rust inside Neon's proxy). Tables, views, and
functions become REST endpoints; authorization is Postgres RLS driven by the
caller's JWT. For CRUD-shaped apps this deletes the backend tier entirely.

## Client usage

Any PostgREST client works; `postgrest-js` is the ergonomic choice:

```ts
import { PostgrestClient } from '@supabase/postgrest-js';

// one factory, token injected per request — works in any SPA
export function db(token: string) {
  return new PostgrestClient(import.meta.env.VITE_NEON_DATA_API_URL, {
    headers: { Authorization: `Bearer ${token}` },       // Neon Auth JWT
  });
}
```

```ts
// reads: filter/order/paginate SERVER-side, embed relations via FKs
const { data: notes, error } = await db(token)
  .from('notes')
  .select(`
    id, title, created_at,
    author:users ( id, name ),
    tags ( label )
  `)                                        // embedded joins from FK graph
  .eq('archived', false)
  .ilike('title', `%${query}%`)
  .order('created_at', { ascending: false })
  .range(0, 24);                            // pagination
if (error) throw new DataApiError(error);   // never swallow .error

// writes return the row — no follow-up read
const { data: created } = await db(token)
  .from('notes')
  .insert({ title, body })                  // RLS decides if allowed
  .select('id, title, created_at')
  .single();

// update/delete are filtered writes — RLS applies on top
await db(token).from('notes').update({ archived: true }).eq('id', noteId);
```

Complex logic — multi-table transactions, computed operations — moves into a
Postgres function, versioned in migrations, still behind RLS:

```sql
-- migrations/0042_claim_task.sql
CREATE OR REPLACE FUNCTION api.claim_next_task()
RETURNS SETOF api.tasks
LANGUAGE sql SECURITY INVOKER AS $$   -- INVOKER: caller's RLS applies
  UPDATE tasks SET claimed_by = auth.user_id(), claimed_at = now()
  WHERE id = (
    SELECT id FROM tasks
    WHERE claimed_by IS NULL
    ORDER BY priority DESC, created_at
    LIMIT 1
    FOR UPDATE SKIP LOCKED            -- concurrency-safe claim
  )
  RETURNING *;
$$;
```

```ts
const { data: task } = await db(token).rpc('claim_next_task');
```

## Architecture rules for backend-less apps

1. **RLS before data.** Enabling the Data API without policies on every
   exposed table is an open database (see auth-rls.md — default-deny, write
   policies first, test the deny cases).
2. **Expose an API schema, not your internals** — a stable contract that
   hides columns clients should never see:

```sql
CREATE SCHEMA api;
CREATE VIEW api.notes AS
  SELECT id, title, body, created_at, owner_id    -- no soft-delete flags,
  FROM public.notes WHERE deleted_at IS NULL;     -- no internal columns

GRANT USAGE ON SCHEMA api TO authenticated;
GRANT SELECT, INSERT, UPDATE ON api.notes TO authenticated;
-- and point the Data API's exposed schema at `api`
```

3. The JWT is the only client credential — publishable keys/tokens in the
   browser are fine *because* RLS assumes every request is hostile. Service
   keys and unpooled connection strings never ship to clients.
4. **Validate in the database** — there's no service layer to catch bad
   data:

```sql
ALTER TABLE notes
  ADD CONSTRAINT title_length CHECK (char_length(title) BETWEEN 1 AND 200),
  ADD CONSTRAINT body_size    CHECK (octet_length(body) <= 100_000);
CREATE TYPE note_visibility AS ENUM ('private', 'team', 'public');
```

5. When you outgrow it (background jobs, third-party API calls, heavy
   compute): add a thin server or edge functions **for those paths only** —
   Data API for CRUD and the server for orchestration coexist on the same
   database.

## Error handling & limits

- Treat PostgREST error codes as part of your API: `PGRST116` (no rows for
  `.single()`), `23505` (unique violation), `42501` (RLS denial — render as
  404/403, never "RLS policy violation" verbatim to users).
- Batch inserts in one call (`insert([...])`) instead of loops — each HTTP
  round trip is a cold-startable compute wake.
