# SQL patterns

## Correctness first — the NULL traps

```sql
-- ☠ excludes rows where status IS NULL (three-valued logic)
SELECT * FROM orders WHERE status != 'cancelled';
-- ✔ say what you mean
SELECT * FROM orders WHERE status IS DISTINCT FROM 'cancelled';

-- ☠ returns NOTHING if the subquery yields a single NULL
SELECT * FROM users WHERE id NOT IN (SELECT user_id FROM banned);
-- ✔ NOT EXISTS is null-safe (and usually faster)
SELECT u.* FROM users u
WHERE NOT EXISTS (SELECT 1 FROM banned b WHERE b.user_id = u.id);
```

## Joins that multiply / filters that sneak

```sql
-- ☠ 1:N join before aggregate inflates the sum (each order counted per item)
SELECT o.customer_id, sum(o.total) FROM orders o
JOIN order_items i ON i.order_id = o.id
GROUP BY 1;

-- ✔ aggregate in a CTE first, join after
WITH item_counts AS (
  SELECT order_id, count(*) AS n_items FROM order_items GROUP BY 1
)
SELECT o.customer_id, sum(o.total) AS revenue, sum(ic.n_items) AS items
FROM orders o LEFT JOIN item_counts ic ON ic.order_id = o.id
GROUP BY 1;
```

```sql
-- ☠ WHERE on the right table turns LEFT JOIN into INNER JOIN
SELECT c.*, o.total FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.status = 'paid';                -- customers with no orders vanish

-- ✔ right-table conditions belong in ON
LEFT JOIN orders o ON o.customer_id = c.id AND o.status = 'paid';
```

## Window functions over self-joins

```sql
-- latest order per customer — THE idiom
SELECT * FROM (
  SELECT o.*,
         row_number() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
  FROM orders o
) t WHERE rn = 1;

-- running total & share-of-total in one pass
SELECT day, revenue,
       sum(revenue) OVER (ORDER BY day)                    AS running_total,
       revenue / sum(revenue) OVER ()                      AS share
FROM daily_revenue;
```

## Dates: half-open ranges, always

```sql
-- ☠ BETWEEN on timestamps includes exactly midnight of Jul 31 and nothing after
WHERE created_at BETWEEN '2026-07-01' AND '2026-07-31'
-- ✔ half-open: full month, DST-proof, composable
WHERE created_at >= '2026-07-01' AND created_at < '2026-08-01'
```

## Performance

1. **Read the plan before guessing**:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT ... ;
-- red flags: Seq Scan on big tables, rows=1 estimated vs rows=500000 actual,
-- Nested Loop over large sets, Sort spilling to disk
```

2. Index what you filter/join/sort by — composite order: equality columns
   first, then the range column:

```sql
-- serves WHERE tenant_id = ? AND status = ? AND created_at > ?
CREATE INDEX idx_orders_tenant_status_created
  ON orders (tenant_id, status, created_at);
-- note: this does NOT serve WHERE status = ? alone (leftmost prefix rule)
```

3. **Sargability** — functions on the column kill the index:

```sql
-- ☠ can't use the index on ts
WHERE date_trunc('day', ts) = '2026-07-04'
-- ✔ range on the raw column
WHERE ts >= '2026-07-04' AND ts < '2026-07-05'

-- ☠ WHERE lower(email) = ...      → ✔ functional index or citext:
CREATE INDEX ON users (lower(email));
```

4. Keyset pagination, not OFFSET:

```sql
-- ☠ OFFSET 100000 reads and discards 100k rows every page
SELECT * FROM orders ORDER BY id LIMIT 25 OFFSET 100000;
-- ✔ seek to where you left off
SELECT * FROM orders WHERE id > $last_seen_id ORDER BY id LIMIT 25;
```

5. `SELECT *` in application code fetches unused columns, breaks covering
   indexes, and couples code to schema — name the columns.

## In application code

Parameterized queries only (see the security track). Migrations: additive
first, destructive later, always reversible (expand→contract, see the
refactor track). Wrap multi-statement writes in explicit transactions with a
deliberately chosen isolation level.
