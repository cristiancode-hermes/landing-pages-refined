# Claude API essentials

> Verify current model ids, pricing, and limits at https://docs.claude.com —
> do not trust hardcoded values found in old code or in your own memory.

## Request shape (Messages API)

```python
import os
import anthropic

MODEL_ID = os.environ["LLM_MODEL_ID"]     # config, never inline

client = anthropic.Anthropic(             # reads ANTHROPIC_API_KEY
    max_retries=4,                        # SDK retries 429/5xx with backoff
    timeout=60.0,                         # never ship without a timeout
)

resp = client.messages.create(
    model=MODEL_ID,
    max_tokens=1024,                      # deliberate: too low truncates output
    system="You are a support assistant for AcmeCo. Answer only from the "
           "provided context. If the answer is not in the context, say so.",
    messages=[
        {"role": "user", "content": "How do I reset my password?"},
    ],
)
print(resp.content[0].text)
print(resp.usage)                         # log tokens on every call
```

## Handle `stop_reason` — every branch, every time

Treating truncated JSON as complete output is the #1 silent-corruption bug in
LLM apps:

```python
msg = client.messages.create(model=MODEL_ID, max_tokens=800, messages=history)

match msg.stop_reason:
    case "end_turn":
        return msg.content[0].text
    case "max_tokens":
        # Output was cut off mid-thought. Never parse it as complete.
        raise TruncatedOutputError(
            f"hit max_tokens={800}; raise the budget or shorten the prompt"
        )
    case "tool_use":
        return run_tools_and_continue(msg)        # see tool-use.md
    case "refusal":
        return handle_refusal(msg)                # surface, don't retry-loop
```

## Streaming (anything user-facing)

```python
with client.messages.stream(
    model=MODEL_ID, max_tokens=1024, messages=history
) as stream:
    for text in stream.text_stream:
        yield text                        # flush to the client incrementally
    final = stream.get_final_message()    # complete message + usage at the end

# TypeScript equivalent
# const stream = client.messages.stream({...});
# for await (const event of stream) { ... }
# const final = await stream.finalMessage();
```

- Set an **idle timeout** around the stream so a stalled connection doesn't
  hang the request forever.
- Parse structured output only from the final message, never from partial
  deltas.

## Structured output — make invalid states unrepresentable

```python
resp = client.messages.create(
    model=MODEL_ID,
    max_tokens=1024,
    messages=[{"role": "user", "content": f"Extract the invoice:\n{doc}"}],
    tools=[{
        "name": "record_invoice",
        "description": "Record the extracted invoice fields.",
        "input_schema": {
            "type": "object",
            "properties": {
                "invoice_number": {"type": "string"},
                "total_cents": {"type": "integer"},
                "currency": {"type": "string", "enum": ["EUR", "USD", "GBP"]},
                "due_date": {"type": ["string", "null"],
                              "description": "ISO 8601, null if absent"},
            },
            "required": ["invoice_number", "total_cents", "currency", "due_date"],
        },
    }],
    tool_choice={"type": "tool", "name": "record_invoice"},   # force the schema
)
invoice = next(b.input for b in resp.content if b.type == "tool_use")
Invoice.model_validate(invoice)           # STILL validate server-side (pydantic/zod)
```

A forced tool call + schema beats "reply with JSON only" prompt-begging.
Validate anyway: the schema constrains shape, not semantics.

## Rules that prevent real bugs

- **Alternate roles.** `messages` must alternate user/assistant; merge
  consecutive same-role turns before sending.
- **Retries**: exponential backoff on 429/500/529; respect `retry-after`.
  Configure the SDK's `max_retries` rather than rebuilding it.
- **Token budgeting**: `client.messages.count_tokens(...)` before sending
  huge contexts; when trimming history, drop or summarize the *middle*
  turns — never the system prompt or the latest user turn.
- **Log request + response** (minus secrets) behind a debug flag, including
  `usage` — you cannot fix a prompt you cannot see, or a bill you don't
  measure.

## Provider-agnostic layer (for Cursor/non-Claude models)

Keep a thin adapter so swapping providers touches one file:

```ts
// llm.ts — the only file allowed to import provider SDKs
export interface ChatMessage { role: "user" | "assistant"; content: string }
export interface CompleteOptions { tools?: ToolDef[]; maxTokens?: number }
export interface LLM {
  complete(system: string, msgs: ChatMessage[], opts?: CompleteOptions): Promise<Completion>;
}
export function makeLLM(cfg: Config): LLM { /* claude | openai | local */ }
```

Normalize role names, tool-call format, and stop reasons at this boundary.
Provider types must never leak into business logic.
