---
name: ml-python
description: >-
  Machine learning with Python — data preparation without leakage, scikit-learn
  and PyTorch training patterns, honest evaluation, and getting models to
  production. Use when training, tuning, evaluating, or deploying ML models,
  building feature pipelines, or reviewing notebooks/experiments.
---

# Machine Learning (Python)

References:

- [data-prep.md](data-prep.md) — splits, leakage prevention, feature pipelines
- [training.md](training.md) — scikit-learn and PyTorch patterns that hold up
- [evaluation.md](evaluation.md) — baselines, metrics, error analysis
- [production.md](production.md) — serialization, serving, monitoring, drift

## Non-negotiables

1. **Baseline before models.** A majority-class predictor, a mean/median, or
   a single heuristic rule goes first. A model that can't clearly beat the
   dumb baseline is a liability with extra steps.
2. **The test set is sacred.** Split before *any* fitting — including scalers,
   encoders, imputers, feature selection, and vocabulary building. Touch the
   test set once, at the end. Tuning against it converts it into a second
   training set (see data-prep.md for the leakage catalog).
3. **Reproducibility is table stakes**: seeds set (and the remaining
   nondeterminism documented), data versioned or hashed, environment pinned,
   every result traceable to (code commit, data version, config).
4. **Metrics match the decision**, not the tutorial: class imbalance kills
   accuracy as a metric; asymmetric costs need cost-weighted evaluation;
   ranking problems need ranking metrics (see evaluation.md).
5. **Simple first.** Linear/tree baselines (logistic regression, LightGBM)
   before deep learning; fine-tune or call a pretrained/foundation model
   before training from scratch. Complexity must buy measured lift.

## For agents

- Never fabricate metric numbers — run the evaluation and paste real output.
- When editing modeling code, state which decisions change results (features,
  splits, hyperparameters) vs. which are refactors; re-run the eval when in
  doubt.
- Notebooks are for exploration; anything that produces a shipped artifact
  gets promoted to a script/pipeline under version control with a fixed
  entrypoint (see production.md).
