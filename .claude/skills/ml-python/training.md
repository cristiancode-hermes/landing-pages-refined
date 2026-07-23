# Training patterns — scikit-learn & PyTorch

## scikit-learn: everything in one Pipeline

```python
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.model_selection import cross_validate

model = Pipeline([("pre", pre), ("clf", HistGradientBoostingClassifier(
    class_weight="balanced",              # imbalance: weights before resampling
    random_state=SEED,
))])
scores = cross_validate(model, X_tr, y_tr, cv=5,
                        scoring=["roc_auc", "average_precision"],
                        return_train_score=True)      # train≫val gap = overfit signal
print(f"PR-AUC {scores['test_average_precision'].mean():.3f} "
      f"± {scores['test_average_precision'].std():.3f}")
```

Tabular default that's hard to beat: gradient-boosted trees (LightGBM /
XGBoost / HistGB) — no scaling needed, native categorical support. Don't
reflexively neural-net tabular data.

Tuning — wide random/optuna search on CV folds, test set untouched:

```python
import optuna

def objective(trial):
    params = {
        "learning_rate": trial.suggest_float("learning_rate", 1e-3, 0.3, log=True),
        "max_depth":     trial.suggest_int("max_depth", 3, 12),
        "l2_regularization": trial.suggest_float("l2", 1e-8, 10, log=True),
    }
    model = Pipeline([("pre", pre), ("clf", HistGradientBoostingClassifier(**params))])
    return cross_validate(model, X_tr, y_tr, cv=5,
                          scoring="average_precision")["test_score"].mean()

study = optuna.create_study(direction="maximize",
                            storage="sqlite:///tuning.db",   # every trial logged
                            study_name="churn-v3")
study.optimize(objective, n_trials=100)
```

## PyTorch: the training loop, done right

```python
def train(model, train_loader, val_loader, cfg):
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model.to(device)
    opt = torch.optim.AdamW(model.parameters(), lr=cfg.lr, weight_decay=0.01)
    sched = torch.optim.lr_scheduler.OneCycleLR(
        opt, max_lr=cfg.lr, total_steps=cfg.epochs * len(train_loader))
    best_val, patience = float("inf"), 0

    for epoch in range(cfg.epochs):
        model.train()
        for xb, yb in train_loader:
            xb, yb = xb.to(device, non_blocking=True), yb.to(device, non_blocking=True)
            opt.zero_grad(set_to_none=True)
            with torch.autocast(device_type=device, dtype=torch.bfloat16):
                loss = F.cross_entropy(model(xb), yb)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            opt.step(); sched.step()

        val_loss = evaluate(model, val_loader, device)      # model.eval() + no_grad inside
        log({"epoch": epoch, "val_loss": val_loss, "lr": sched.get_last_lr()[0]})

        if val_loss < best_val:                              # checkpoint on best VAL metric
            best_val, patience = val_loss, 0
            torch.save({"model": model.state_dict(), "cfg": vars(cfg),
                        "epoch": epoch, "val_loss": val_loss}, "best.pt")
        elif (patience := patience + 1) >= cfg.early_stop:   # early stop with patience
            break
    return best_val

@torch.no_grad()
def evaluate(model, loader, device):
    model.eval()                       # forgetting this corrupts batchnorm/dropout
    losses = [F.cross_entropy(model(x.to(device)), y.to(device)).item()
              for x, y in loader]
    return sum(losses) / len(losses)
```

- **Overfit one batch first** — if the model can't reach ~zero loss on 32
  samples, the bug is in the wiring, not the hyperparameters:

```python
xb, yb = next(iter(train_loader))
for step in range(300):
    loss = step_fn(xb, yb)
assert loss < 0.01, f"can't overfit one batch (loss={loss:.3f}) — check model/loss/data"
```

- Determinism: seed `torch`, `numpy`, `random`; full CUDA determinism costs
  speed (`torch.use_deterministic_algorithms(True)`) — decide per project
  and write the decision down.
- DataLoader: `num_workers>0`, `pin_memory=True`; heavy augmentation on
  workers. Profile before blaming the GPU — the input pipeline is usually
  the bottleneck:

```python
with torch.profiler.profile(activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA]) as p:
    train_some_steps()
print(p.key_averages().table(sort_by="cuda_time_total", row_limit=15))
```

## Fine-tune before training from scratch

```python
from transformers import AutoModelForSequenceClassification, TrainingArguments, Trainer

model = AutoModelForSequenceClassification.from_pretrained(
    "answerdotai/ModernBERT-base", num_labels=3)
# freeze the backbone, train the head first; then unfreeze with a 10× lower LR
for p in model.base_model.parameters():
    p.requires_grad = False
```

From-scratch training needs justification (domain gap, license, scale) —
for text/vision/audio, pretrained + fine-tune is the default.
