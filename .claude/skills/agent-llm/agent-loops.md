# Agent loops

The core agent shape: **gather context → act → verify → repeat**, with a hard
stop condition. Everything else is decoration.

## A bounded loop skeleton

```python
@dataclass
class Budget:
    max_iterations: int = 12
    max_cost_usd: float = 2.00
    max_wall_seconds: int = 600

def run(task: str, budget: Budget) -> AgentResult:
    state = AgentState(task=task, history=[], cost=0.0, started=time.time())

    while True:
        # ---- stop conditions FIRST, checked every iteration ----
        if state.iterations >= budget.max_iterations:
            return AgentResult.exhausted(state, "iteration budget")
        if state.cost >= budget.max_cost_usd:
            return AgentResult.exhausted(state, "cost budget")
        if time.time() - state.started > budget.max_wall_seconds:
            return AgentResult.exhausted(state, "wall clock")

        step = plan_next_step(state)          # one LLM call
        state.cost += step.usage_cost

        if step.kind == "done":
            evidence = verify(state)          # ← run checks; don't trust the claim
            if evidence.ok:
                return AgentResult.success(state, evidence)
            state.record(f"verification failed: {evidence.report}")
            continue                          # loop again with the failure in context

        if step.kind == "blocked":
            return AgentResult.blocked(state, step.question)   # ask the human

        outcome = execute(step.action)        # tool call / code edit / command
        state.record(observe(outcome))        # feed REALITY back, not intentions
        state.iterations += 1
```

Design points baked into that skeleton:

- **Stop conditions first.** Iterations, cost, and wall clock — an agent
  without a budget is a bill.
- **"Done" requires evidence.** The verify step runs tests / re-reads files /
  queries the API. A model's claim that it worked is not a result.
- **Blocked is a first-class outcome.** Escalating a genuine ambiguity to a
  human beats guessing; make it cheap to do.
- **Observations are ground truth.** Record command output and diffs, not the
  model's summary of what it intended.

## Doom-loop detection

```python
def is_doom_loop(state, action) -> bool:
    recent = [a for a in state.actions[-4:]]
    return recent.count(action) >= 2          # same action, same args, again

if is_doom_loop(state, step.action):
    state.record("SYSTEM: this exact action already failed twice. "
                 "Change strategy or report blocked.")
```

| Failure | Symptom | Fix |
|---|---|---|
| Doom loop | same failing action repeated | detect repeats → force strategy change or abort |
| Premature victory | "done" without verification | evidence-gated done (above) |
| Context rot | quality decays over long runs | compaction + pinned task statement |
| Scope creep | agent "improves" unrelated things | diff gate: every changed file maps to the task |

## Context discipline

- Pin the task statement and constraints; they survive every compaction.
- Summarize or drop old tool results as the loop runs — keep the *conclusions*
  ("tests pass on module X"), drop the 400-line output that proved it.
- Past ~60% context fill, quality measurably degrades: compact proactively at
  a threshold, not reactively at the limit.

## Subagents

- Fresh context + narrow contract: task in, structured report out. Don't let
  them inherit the whole conversation.
- **Single-writer rule**: parallel subagents for *reading* (research, search
  fan-out); merge findings, then one agent mutates serially. Two agents
  editing one repo concurrently is a merge conflict generator.
- Make the report format explicit in the subagent prompt ("Return: files
  found, relevant line ranges, one-paragraph conclusion") — unstructured
  essays don't merge.

## Checkpointing

Persist state (like `MEMORY.md` in this kit) at every meaningful step so a
crashed or restarted loop **resumes** instead of restarting: task, decisions
made, files touched, next step. The shift-log format at the top of MEMORY.md
is exactly this.
