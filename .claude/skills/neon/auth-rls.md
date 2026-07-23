# Neon Auth + Row-Level Security

## Neon Auth

Managed authentication where **users and sessions live in your Postgres**
(the `neon_auth` schema) — no separate user store to sync, and user data is
JOIN-able like any table:

```sql
-- enrich app rows with auth users directly
SELECT n.title, u.name AS author
FROM notes n
JOIN neon_auth.users_sync u ON u.id = n.owner_id
WHERE u.deleted_at IS NULL;
```

- SDKs handle signup/login/OAuth/session UI; the session issues a **JWT**
  the Data API and RLS consume.
- Bring-your-own-auth: point Neon at any provider's **JWKS URL** (Clerk,
  Auth0, Stack Auth, custom) — the RLS patterns below stay identical.
- Never trust client-asserted identity: user id comes from the *verified*
  JWT (`auth.user_id()` in policies), never from a request body or query
  param.

## RLS: authorization as schema

```sql
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;   -- default deny from here on

-- owner-only CRUD, each operation explicit
CREATE POLICY notes_select ON notes FOR SELECT TO authenticated
  USING (owner_id = auth.user_id());

CREATE POLICY notes_insert ON notes FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.user_id());

CREATE POLICY notes_update ON notes FOR UPDATE TO authenticated
  USING (owner_id = auth.user_id())            -- which rows you may target
  WITH CHECK (owner_id = auth.user_id());      -- what they may become (no reassign)

-- deliberately NO delete policy = nobody deletes (add consciously)
```

Rules that prevent real incidents:

- **`USING` filters reads; `WITH CHECK` guards writes.** An UPDATE policy
  without `WITH CHECK` lets users move rows out of their own scope.
- **Multi-tenant**: `tenant_id` on every table and in the JWT claims; every
  policy leads with it, and composite indexes must too:

```sql
CREATE POLICY docs_tenant ON documents FOR ALL TO authenticated
  USING  (tenant_id = (auth.jwt()->>'tenant_id')::uuid)
  WITH CHECK (tenant_id = (auth.jwt()->>'tenant_id')::uuid);

-- without this, RLS turns every query into a seq scan:
CREATE INDEX ON documents (tenant_id, created_at DESC);
```

- **Shared/role-based access** joins a membership table — wrap the check in
  a helper to avoid recursive policy evaluation and to keep policies
  readable:

```sql
CREATE FUNCTION can_access_project(pid uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$    -- DEFINER: bypasses RLS inside
  SELECT EXISTS (
    SELECT 1 FROM project_members
    WHERE project_id = pid AND user_id = auth.user_id()
  );
$$;

CREATE POLICY tasks_by_membership ON tasks FOR SELECT TO authenticated
  USING (can_access_project(project_id));
```

- Wrap per-row-evaluated claims in a scalar subquery so they're computed
  once per statement: `USING (tenant_id = (SELECT (auth.jwt()->>'tenant_id')::uuid))`.
- Migrations and background jobs connect as a privileged role that bypasses
  RLS — which is exactly why that connection string must never reach a
  client.

## Test policies like code — allow AND deny

```sql
-- tests/rls/notes.sql — run in CI on a Neon branch
BEGIN;
  SELECT set_config('request.jwt.claims',
                    '{"sub":"user-a","tenant_id":"t1"}', true);
  INSERT INTO notes (title, owner_id) VALUES ('mine', 'user-a');

  -- allow case: owner sees own note
  SELECT ok(count(*) = 1) FROM notes WHERE title = 'mine';

  -- DENY case: user B sees nothing (the test most suites forget)
  SELECT set_config('request.jwt.claims',
                    '{"sub":"user-b","tenant_id":"t1"}', true);
  SELECT ok(count(*) = 0) FROM notes WHERE title = 'mine';

  -- DENY case: user B cannot steal via UPDATE either
  UPDATE notes SET owner_id = 'user-b' WHERE title = 'mine';  -- expect 0 rows
ROLLBACK;
```

A missing deny-test is how "everyone can read everyone's data" ships. Add a
CI guard that fails when a table in the exposed schema has RLS disabled:

```sql
SELECT relname FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'api' AND c.relkind = 'r' AND NOT c.relrowsecurity;
-- CI fails if this returns any rows
```
