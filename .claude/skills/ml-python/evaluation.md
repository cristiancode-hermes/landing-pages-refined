# Evaluation — honest numbers

## Pick metrics that match the decision

| Situation | Use | Avoid |
|---|---|---|
| Balanced classification | accuracy, F1, ROC-AUC | — |
| Imbalanced classification | **PR-AUC**, recall@precision, cost-weighted | accuracy ("99% accurate" fraud model that flags nothing) |
| Probabilities used downstream | calibration (reliability curve, Brier) | raw AUC alone |
| Regression | MAE (interpretable), RMSE (penalizes big misses), quantile loss | R² alone on non-IID data |
| Ranking / retrieval | NDCG, MRR, recall@k | accuracy |

Report **with uncertainty** — a 0.3-point improvement inside the noise band
is not an improvement:

```python
import numpy as np
from sklearn.metrics import average_precision_score

def bootstrap_ci(y_true, y_score, metric, n=2000, seed=0):
    rng = np.random.default_rng(seed)
    idx = np.arange(len(y_true))
    stats = [metric(y_true[s], y_score[s])
             for s in (rng.choice(idx, len(idx), replace=True) for _ in range(n))]
    return np.percentile(stats, [2.5, 97.5])

lo, hi = bootstrap_ci(y_te, scores, average_precision_score)
print(f"PR-AUC {average_precision_score(y_te, scores):.3f}  (95% CI {lo:.3f}–{hi:.3f})")
```

Threshold-based metrics require choosing the threshold on **validation**
data for the business cost — 0.5 is not a law:

```python
prec, rec, thr = precision_recall_curve(y_val, val_scores)
ok = prec[:-1] >= 0.90                      # requirement: ≥90% precision
best_thr = thr[ok][np.argmax(rec[:-1][ok])] # …then maximize recall
```

Calibrate if anyone treats outputs as probabilities:

```python
from sklearn.calibration import CalibratedClassifierCV, CalibrationDisplay
calibrated = CalibratedClassifierCV(model, method="isotonic", cv=5).fit(X_tr, y_tr)
CalibrationDisplay.from_estimator(calibrated, X_te, y_te, n_bins=10)  # eyeball it
```

## The comparison discipline

```python
results = {}
results["baseline_majority"] = evaluate(DummyClassifier(strategy="most_frequent"))
results["baseline_logreg"]   = evaluate(make_logreg_pipeline())
results["candidate_gbdt"]    = evaluate(make_gbdt_pipeline())
print(pd.DataFrame(results).T)     # same splits, same metric, one table
```

Improvements are claimed over the **simple model**, with the dumb baseline
as the floor. Change one thing at a time — an experiment that changes
features *and* model *and* seed proves nothing.

## Error analysis (where the real gains are)

Slice performance — aggregate metrics hide the segment where the model is
dangerous:

```python
test = X_te.assign(y=y_te, score=scores, pred=scores > best_thr)
by_slice = (test.groupby(["region", pd.qcut(test.account_age_days, 4)])
                .apply(lambda g: pd.Series({
                    "n": len(g),
                    "pr_auc": average_precision_score(g.y, g.score) if g.y.nunique() > 1 else np.nan,
                    "fpr": ((g.pred) & (~g.y.astype(bool))).mean(),
                })))
print(by_slice.sort_values("pr_auc"))   # the worst slice is your next task
```

Read actual failures — sample 30-50 worst errors and label the *causes*;
fixing the top cause usually beats any hyperparameter search:

```python
worst_fn = test[(~test.pred) & (test.y == 1)].nlargest(50, "amount")
worst_fn.to_csv("review/false_negatives.csv")   # go read them, tag causes
```

- Check label noise before blaming the model: if human review disagrees
  with 15% of labels, that's your ceiling.
- Errors clustering in a region of feature space = missing features or
  missing training data, not a missing architecture.
