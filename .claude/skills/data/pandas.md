# pandas patterns

## Look before you leap — always

```python
df = pd.read_csv("orders.csv", dtype={"order_id": "string"},
                 parse_dates=["created_at"], usecols=COLS)   # load less, typed
df.info(memory_usage="deep")      # dtypes + memory — mixed 'object' cols = trouble
df.isna().sum()                   # missingness map before any transform
df["order_id"].is_unique          # key assumption — verify, don't assume
df.duplicated(subset=["order_id"]).sum()
```

## Writes: one clear owner

```python
# ☠ chained indexing — silently does nothing (SettingWithCopy)
df[df.amount > 0]["flagged"] = True

# ✔ .loc with a mask — one read, one write
df.loc[df.amount > 0, "flagged"] = True

# ✔ pipelines: chain with assign/pipe, never mutate in place across cells
clean = (
    raw
    .rename(columns=str.lower)
    .assign(
        amount_eur=lambda d: d.amount_cents / 100,
        month=lambda d: d.created_at.dt.to_period("M"),
    )
    .query("status != 'test'")
    .pipe(validate_schema)          # fail loudly at the boundary
)
```

## Merges are where data dies

```python
out = orders.merge(customers, on="customer_id", how="left",
                   validate="many_to_one",     # raises on dupe keys — the row-explosion guard
                   indicator=True)             # _merge column shows unmatched rows

assert len(out) == len(orders), "left join changed the row count!"
out["_merge"].value_counts()                   # how many orders had no customer?
```

`validate=` + `indicator=` catch on the spot what would otherwise ruin every
downstream number three notebooks later.

## Vectorize — never iterrows for transforms

```python
# ☠ 1000× slower and mutation-prone
for i, row in df.iterrows():
    df.loc[i, "band"] = "high" if row.amount > 100 else "low"

# ✔ the ladder: vectorized op → np.where/np.select → .map → .apply (last resort)
df["band"] = np.where(df.amount > 100, "high", "low")

df["segment"] = np.select(
    [df.amount > 1000, df.amount > 100],
    ["vip", "high"],
    default="standard",
)
df["country"] = df.country_code.map(COUNTRY_NAMES)   # dict lookup
```

## groupby — named aggregation, deliberate counting

```python
summary = (
    df.groupby("customer_id", as_index=False)
      .agg(
          total=("amount_eur", "sum"),
          n_orders=("order_id", "size"),      # size counts rows
          n_paid=("paid_at", "count"),        # count counts NON-NULLS — different!
          first_order=("created_at", "min"),
      )
)

# latest row per group — the idiom
latest = df.sort_values("created_at").groupby("customer_id").tail(1)
```

## Dates, NaN, categories

```python
df["ts"] = pd.to_datetime(df.ts, errors="raise", utc=True)   # raise > silent coerce
bad = pd.to_datetime(df.ts, errors="coerce")                  # if you must coerce…
print(f"unparseable timestamps: {bad.isna().sum()}")          # …count the damage

df[df.email.isna()]        # ✔ NaN != NaN — never  df[df.email == np.nan]
df["status"] = df.status.astype("category")   # low-cardinality strings: ~10× memory
```

Distinguish "missing" from "zero" from "not applicable" in the schema notes —
`fillna(0)` on a column where NaN means "unknown" fabricates data.

## Performance & scale

- Parquet over CSV for anything you re-read: `df.to_parquet(...)` — typed,
  compressed, 10× faster loads.
- Doesn't fit / too slow? Try DuckDB or polars **before** a cluster:

```python
import duckdb
top = duckdb.query("""
    SELECT customer_id, sum(amount_eur) AS total
    FROM df GROUP BY 1 ORDER BY 2 DESC LIMIT 100
""").df()                                  # queries the pandas frame in place
```

## Output hygiene

Round only at display time; keep full precision in the pipeline. Sort
explicitly before relying on order. `reset_index(drop=True)` after filters
when the index isn't meaningful.
