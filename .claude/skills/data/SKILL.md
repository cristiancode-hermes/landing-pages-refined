---
name: data
description: >-
  Data work with pandas and SQL — analysis, transformations, ETL, and query
  writing/optimization. Use when manipulating dataframes, writing SQL,
  designing schemas, or debugging slow queries or wrong aggregates.
---

# Data

References:

- [pandas.md](pandas.md) — idiomatic, non-footgun pandas
- [sql.md](sql.md) — correct and fast SQL

## Principles

- **Look at the data before transforming it.** `df.head()`, `df.dtypes`,
  `df.isna().sum()`, row counts at each pipeline stage. Most "bugs" are
  surprises in the data (dupes, nulls, mixed types, stray whitespace), not in
  the code.
- **Assert your assumptions**: uniqueness of keys, non-null of joins' columns,
  expected row-count deltas after merges. One `assert df["id"].is_unique`
  catches the silent row-explosion join that ruins every downstream number.
- **Never mutate source data.** Raw in, derived out; transformations
  re-runnable end to end (a script/notebook that goes raw → result with no
  manual steps in between).
- Aggregations get a sanity check against a known total ("do the parts sum to
  the whole?") before anyone sees them.
- Mind types early: parse dates on load, use categoricals for low-cardinality
  strings, decimals for money (never float).

## For agents

Report findings with the query/code that produced them, so numbers are
reproducible. If a result looks surprising, verify it a second, independent
way before presenting it.
