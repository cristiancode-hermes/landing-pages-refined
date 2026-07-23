# Prompt caching

Prompt caching makes repeated prefixes (system prompt, tool defs, long
documents) dramatically cheaper and faster. It only works if you design for it.

## How it prices out

- Cache **write**: ~1.25× normal input price (first call).
- Cache **read**: ~0.1× normal input price (every subsequent call).
- Break-even from the **second** call onward. Don't enable it for one-shots.
- TTL ~5 minutes, refreshed on every hit (a 1-hour TTL tier exists at a
  higher write cost — for long-idle agents).

## Request layout — stable prefix first

One changed byte invalidates everything **after** it. Order the request so
volatile content comes last:

```python
resp = client.messages.create(
    model=MODEL_ID,
    max_tokens=1024,
    tools=TOOLS,                                  # 1. most stable
    system=[
        {
            "type": "text",
            "text": SYSTEM_RULES,                 # 2. stable rules
        },
        {
            "type": "text",
            "text": PRODUCT_MANUAL,               # 3. big stable document
            "cache_control": {"type": "ephemeral"},   # breakpoint after the stable part
        },
    ],
    messages=history,                             # 4. volatile conversation
)
```

Common cache-killers to hunt down:

```python
# ☠ each of these poisons the cache on every call
system = f"Today is {datetime.now()}. You are..."       # timestamp in prefix
system = f"[request-id: {uuid4()}] You are..."          # per-request id
tools = sorted(TOOLS, key=lambda t: random.random())    # unstable ordering
history = [summarize(m) for m in history]               # re-summarizing old turns
```

Fixes: put "today's date" in the **latest user turn**; keep ids in metadata,
not prompt text; serialize tools deterministically; append to history instead
of rewriting it (compact only when crossing a size threshold, accepting one
deliberate cache miss).

## Multi-turn conversations

Add a second breakpoint at the end of the last user turn; on the next call
the whole previous conversation reads from cache:

```python
messages=[
    *previous_turns,
    {"role": "user", "content": [
        {"type": "text", "text": user_input,
         "cache_control": {"type": "ephemeral"}},
    ]},
]
```

Up to 4 breakpoints total; typical layout is 1-2 (end of tools/system+docs,
end of conversation). Minimum cacheable prefix is ~1024 tokens (model-
dependent) — don't sprinkle breakpoints on tiny prefixes.

## Cache-aware scheduling

A poll loop firing every 6 minutes pays full price every time; every 4
minutes is nearly free. Batch related calls close together; for agent loops,
prefer several quick iterations over sleeping past the TTL between steps.

## Verify it's actually working

```python
u = resp.usage
print(u.cache_creation_input_tokens,   # >0 on first call
      u.cache_read_input_tokens,       # >0 on subsequent calls — if 0, debug
      u.input_tokens)                  # uncached remainder (should be small)
```

If reads stay 0: dump two consecutive requests to disk and diff them
byte-for-byte — something in the "stable" prefix isn't. Alert if the cache
hit rate drops in production; a silent regression here is a silent 10× cost
increase.
