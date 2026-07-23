# Data preparation & leakage prevention

Leakage — information from outside the training fold influencing training —
is the #1 cause of "95% in the notebook, useless in production".

## Split correctly for the data's structure

```python
from sklearn.model_selection import (
    train_test_split, TimeSeriesSplit, GroupKFold, StratifiedKFold)

# IID tabular: stratify classification targets
X_tr, X_te, y_tr, y_te = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=SEED)

# Time series: train on the past, evaluate on the future — ALWAYS
tscv = TimeSeriesSplit(n_splits=5, test_size=90)      # e.g. 90-day eval windows
for tr_idx, te_idx in tscv.split(X_sorted_by_time):
    ...

# Grouped data (multiple rows per user/patient/device): split by GROUP —
# the same entity in train and test measures memorization, not generalization
gkf = GroupKFold(n_splits=5)
for tr_idx, te_idx in gkf.split(X, y, groups=df["user_id"]):
    ...
```

- A random split on temporal data is leakage by construction. No feature may
  use information after the prediction timestamp — rolling stats must be
  shifted:

```python
# ☠ includes today's value in today's feature
df["spend_7d"] = df.groupby("user_id")["spend"].transform(lambda s: s.rolling(7).mean())
# ✔ known strictly BEFORE the prediction moment
df["spend_7d"] = (df.groupby("user_id")["spend"]
                    .transform(lambda s: s.shift(1).rolling(7).mean()))
```

- Dedupe (and near-dedupe) **before** splitting, or duplicates straddle the
  boundary.

## The leakage catalog (check every one)

```python
# ☠ scaler fitted on ALL data — test-set statistics leak into training
scaler = StandardScaler().fit(X)               # sees X_test!
X_tr = scaler.transform(X_tr)

# ✔ fit on train only — Pipeline makes this automatic inside CV
model = Pipeline([("pre", pre), ("clf", clf)])
cross_validate(model, X_tr, y_tr, cv=5)        # pre refits per fold
```

- Target leakage: features that proxy the label or are recorded **after**
  the outcome (`n_late_payments` when predicting default; `final_status`
  columns). Suspect any feature with implausibly high importance —
  investigate before celebrating:

```python
imp = permutation_importance(model, X_val, y_val, n_repeats=5, random_state=SEED)
suspicious = [c for c, v in zip(X.columns, imp.importances_mean) if v > 0.3]
```

- Oversampling (SMOTE etc.) before splitting → synthetic points leak across
  the boundary. Resample **inside** the training fold only
  (`imblearn.pipeline.Pipeline` handles this).
- CV score used for both tuning *and* reporting → nested CV, or a held-out
  test set touched once for the final number.

## Feature pipelines

```python
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

pre = ColumnTransformer([
    ("num", Pipeline([
        ("impute", SimpleImputer(strategy="median", add_indicator=True)),  # missingness is signal
        ("scale", StandardScaler()),
    ]), num_cols),
    ("cat", OneHotEncoder(handle_unknown="infrequent_if_exist",   # prod WILL send unseen cats
                          min_frequency=20), cat_cols),
], remainder="drop", verbose_feature_names_out=False)
```

- Document each engineered feature: definition, source columns, and **the
  timestamp at which it is knowable** — that last field is your leakage
  audit.
- Validate schema at pipeline entry — fail loudly on drift, not silently on
  garbage:

```python
import pandera as pa

schema = pa.DataFrameSchema({
    "amount":  pa.Column(float, pa.Check.ge(0)),
    "country": pa.Column(str, pa.Check.isin(KNOWN_COUNTRIES), nullable=True),
    "created": pa.Column(pa.DateTime, pa.Check.lt(pd.Timestamp.now(tz="UTC"))),
})
df = schema.validate(df, lazy=True)     # collects ALL violations, then raises
```
