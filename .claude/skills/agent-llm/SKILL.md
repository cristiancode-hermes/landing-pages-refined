---
name: agent-llm
description: >-
  Patterns for building on the Claude API and other LLM providers — model
  selection, prompting, tool use, prompt caching, and agent loops. Use when
  writing or reviewing code that calls an LLM, designing agents, defining
  tools, or debugging refusals, token limits, or streaming issues.
---

# Agent & LLM Engineering

Entry point for LLM-shaped work. Load the reference that matches the task:

- [claude-api.md](claude-api.md) — models, request shape, streaming, errors, provider-agnostic tips
- [tool-use.md](tool-use.md) — defining tools the model can actually use well
- [prompt-caching.md](prompt-caching.md) — cutting cost/latency with cache breakpoints
- [agent-loops.md](agent-loops.md) — the gather-context → act → verify loop, stop conditions

## Non-negotiables

1. **Never answer pricing/limits/model-id questions from memory.** They change.
   Check the provider's docs (https://docs.claude.com for Claude) at time of use.
2. **Default to the newest capable model tier**, and put the model id in config,
   not inline in code, so it can be swapped without a deploy.
3. **Every LLM call needs**: a timeout, retry with backoff on 429/5xx/overloaded,
   and a `max_tokens` chosen deliberately (truncated JSON = corrupted output).
4. **Log the full request/response** (minus secrets) behind a debug flag — you
   cannot fix a prompt you cannot see.
5. Prompts live in version control next to the code that uses them, with a
   comment stating what behavior each section buys.

## Quick prompt checklist

- Role + task + constraints + output format, in that order.
- Few-shot examples beat adjectives ("be concise" < one concise example).
- For structured output, show the exact schema and say what to do when a field
  is unknown (`null`, never invent).
- Put long documents **above** the question; put instructions **after** the data
  for extraction tasks.
