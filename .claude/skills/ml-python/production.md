# ML in production

## From notebook to artifact

One entrypoint per stage, one config object, no laptop paths:

```python
# train.py — python train.py --config configs/churn_v3.yaml
class TrainConfig(BaseSettings):
    data_version: str
    model_params: dict
    seed: int = 42
    experiment: str = "churn"

def main(cfg: TrainConfig):
    mlflow.set_experiment(cfg.experiment)
    with mlflow.start_run():
        mlflow.log_params({**cfg.model_params, "data_version": cfg.data_version,
                           "git_sha": git_sha()})
        model = build_pipeline(cfg).fit(X_tr, y_tr)
        metrics = evaluate_all(model, X_te, y_te)
        mlflow.log_metrics(metrics)
        mlflow.sklearn.log_model(model, "model",
                                 registered_model_name="churn")   # versioned artifact
```

"Which model is in prod and how was it trained?" must have a one-click
answer: params, metrics, data hash, git commit, artifact — per run.

Serialize the **whole pipeline** (preprocessing + model), never the bare
estimator; for PyTorch, `state_dict` + code + config (never pickle a class
you'll refactor):

```python
joblib.dump(model, "model.joblib")                     # sklearn pipeline
torch.save({"state_dict": m.state_dict(), "config": cfg}, "model.pt")
# cross-language serving → ONNX
```

Ship a model card next to the artifact: intended use, training window, eval
metrics **per segment**, known failure modes.

## Serving

```python
# serve.py — FastAPI wrapper with an explicit contract
app = FastAPI()
model = joblib.load("model.joblib")
MODEL_VERSION = os.environ["MODEL_VERSION"]

class ChurnRequest(BaseModel):
    account_age_days: int = Field(ge=0)
    plan: Literal["free", "pro", "enterprise"]
    monthly_spend: float = Field(ge=0)
    # unknown fields rejected, garbage never becomes a prediction
    model_config = ConfigDict(extra="forbid")

@app.post("/predict")
def predict(req: ChurnRequest, response: Response):
    features = pd.DataFrame([req.model_dump()])
    score = float(model.predict_proba(features)[0, 1])
    response.headers["x-model-version"] = MODEL_VERSION
    log_prediction(model_version=MODEL_VERSION,          # your future training data
                   features=req.model_dump(), score=score)
    return {"churn_probability": score, "model_version": MODEL_VERSION}
```

- Keep the previous model warm for instant rollback; canary or **shadow**
  (predict-but-don't-act) before full cutover.
- Batch offline scoring beats real-time serving when latency isn't a real
  requirement — 10× simpler to operate.

## Monitoring & drift

Models degrade silently — the service returns 200s while accuracy rots.

```python
def psi(expected: np.ndarray, actual: np.ndarray, bins=10) -> float:
    """Population Stability Index per feature: <0.1 stable, 0.1–0.25 watch, >0.25 alert."""
    cuts = np.quantile(expected, np.linspace(0, 1, bins + 1))
    cuts[0], cuts[-1] = -np.inf, np.inf
    e = np.histogram(expected, cuts)[0] / len(expected) + 1e-6
    a = np.histogram(actual, cuts)[0] / len(actual) + 1e-6
    return float(np.sum((a - e) * np.log(a / e)))

# nightly job: training distribution vs last 24h of prediction logs
for col in NUMERIC_FEATURES:
    score = psi(train_ref[col].values, live_window[col].values)
    push_metric("feature_psi", score, tags={"feature": col})
```

- **Data drift**: PSI/KS per feature vs training reference; alert on schema
  changes, new categories, null-rate spikes — cheap alarms that catch
  upstream breakage.
- **Prediction drift**: monitor the output distribution; a fraud model whose
  positive rate doubles overnight is telling you something.
- **Ground-truth lag**: when labels arrive late (chargebacks, churn),
  backfill actual-vs-predicted dashboards as labels land; define acceptable
  degradation *before* launch so retraining is a runbook, not a panic.
- Retraining: scheduled or drift-triggered — and every retrain runs the full
  eval gauntlet against the incumbent. Champions are dethroned by evidence,
  not recency.
