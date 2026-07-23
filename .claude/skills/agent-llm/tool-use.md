# Tool use (function calling)

A tool definition is a prompt. The model decides *whether* and *how* to call
it purely from the name, description, and schema — invest there.

## Anatomy of a good tool definition

```python
SEARCH_ORDERS = {
    "name": "search_orders",                      # verb_noun, unambiguous
    "description": (
        "Search the customer's own orders by status and date range. "
        "Use this when the user asks about their orders, deliveries, or "
        "refund status. Do NOT use it for product catalog questions — "
        "use search_products for those. Returns at most 20 orders, newest "
        "first, with id, status, total, and item summaries."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "status": {
                "type": "string",
                "enum": ["pending", "shipped", "delivered", "refunded"],
                "description": "Filter by order status. Omit for all statuses.",
            },
            "since": {
                "type": "string",
                "description": "ISO date lower bound, e.g. '2026-01-01'. "
                               "Omit for no lower bound.",
            },
            "limit": {"type": "integer", "minimum": 1, "maximum": 20, "default": 10},
        },
        "required": [],
    },
}
```

The description answers four questions: what it does, when to use it, when
**not** to (and what to use instead), and what it returns. Enums over free
strings whenever the value set is closed.

## The tool loop — complete and bounded

```python
MAX_ROUNDS = 8

def run_agent(client, history: list) -> str:
    for _ in range(MAX_ROUNDS):
        msg = client.messages.create(
            model=MODEL_ID, max_tokens=1024,
            tools=TOOLS, messages=history,
        )
        if msg.stop_reason != "tool_use":
            return "".join(b.text for b in msg.content if b.type == "text")

        history.append({"role": "assistant", "content": msg.content})
        results = []
        for block in msg.content:
            if block.type != "tool_use":
                continue
            results.append({
                "type": "tool_result",
                "tool_use_id": block.id,
                **execute(block.name, block.input),     # below
            })
        history.append({"role": "user", "content": results})

    raise ToolLoopBudgetExceeded(f"no answer after {MAX_ROUNDS} rounds")
```

## Executing calls: validate, contain failures, return structure

```python
def execute(name: str, args: dict) -> dict:
    try:
        handler = HANDLERS[name]                       # KeyError = model hallucinated a tool
        parsed = handler.schema.model_validate(args)   # pydantic re-validation
        output = handler.fn(parsed)
        return {"content": compact(output)}
    except ValidationError as e:
        # Feed the error BACK to the model so it self-corrects — don't crash.
        return {"content": f"Invalid arguments: {e}", "is_error": True}
    except DomainError as e:
        return {"content": f"Could not complete: {e}", "is_error": True}
```

- **Validate every call server-side.** The schema constrains the model; it
  does not guarantee correctness.
- **Tool results are prompts too.** Return compact, relevant data; truncate
  with an explicit marker so the model knows:
  `f"{rows[:50]}\n[truncated: {len(rows)-50} more rows — refine the query]"`.
- Idempotent reads auto-run; **writes and irreversible actions gate on
  confirmation** (human approval or an allowlist policy). Tag each tool
  `readonly: bool` in your registry and enforce it centrally.

## Steering tool choice

```python
tool_choice={"type": "auto"}                       # default: model decides
tool_choice={"type": "any"}                        # must call SOME tool
tool_choice={"type": "tool", "name": "record_invoice"}   # must call THIS one
```

Use `tool_choice` when a call is required — don't prompt-beg ("please use
the tool"). Detect doom loops: if the model issues the same tool call with
identical args twice in a row, inject a corrective user turn or abort.

## Design heuristics

- Fewer, more powerful tools beat many overlapping ones. If two tools are
  confusable, the model will confuse them — merge them or sharpen the
  boundary in both descriptions.
- Prefer one `search_x(query, filters)` over five `get_x_by_*` variants.
- Token cost is part of the design: a tool that returns 200KB of JSON wastes
  context and buries the answer — filter and summarize server-side.
