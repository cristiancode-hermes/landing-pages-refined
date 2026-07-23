# ESLint MCP server — lint as a tool, not a guess

ESLint ships an MCP server (v9.26+) so agents lint files through the real
linter — the project's own config, plugins, and versions — instead of
predicting what lint would say.

## Two ways to run it

```bash
npx eslint --mcp            # built into the ESLint CLI (uses project ESLint)
npx @eslint/mcp@latest      # standalone package, same server
```

## Registration

Already registered in this kit's `.mcp.json` (Claude Code) and
`opencode.json` (OpenCode) as `eslint`. For other hosts:

```jsonc
// .vscode/mcp.json — VS Code / Copilot agent mode
{ "servers": { "ESLint": { "type": "stdio", "command": "npx", "args": ["@eslint/mcp@latest"] } } }

// Cursor: Settings → MCP → add server, command: npx @eslint/mcp@latest
```

The server is **stdio + npx**: it needs `node`/`npx` on PATH and works out
of the box in a repo that has ESLint installed (`npm i -D eslint`). It lints
with the project's own `eslint.config.*`; without one it reports accordingly
— set the config up first (see [flat-config.md](flat-config.md)).

## The agent loop

1. **Edit** JS/TS files.
2. **Lint the touched files** via the MCP tool (or `npx eslint <paths>`).
3. **Fix** — mechanical issues with `npx eslint --fix <paths>`, real issues
   by editing; re-lint until clean.
4. Only then report done. A diff that fails lint fails the verification
   standard — the verifier or CI will catch it anyway; catch it first.

Prompts like "lint and fix this file", "lint the files in this diff and
explain the errors" resolve to MCP tool calls in Claude Code/Copilot/Cursor
once the server is registered.

## Rules of engagement (same as SKILL.md, enforced here)

- Don't add `eslint-disable` comments to make the loop converge — a disable
  needs a justification comment and should be rare enough to stand out in
  review.
- Don't edit `eslint.config.*` to weaken a rule as a "fix". Config changes
  are deliberate, user-approved acts.
- MCP server unavailable (no network for npx, no host support)? Fall back to
  `npx eslint` in the shell — the discipline is identical.

## CI floor

The MCP loop is interactive; CI is the backstop. Keep both:

```yaml
- run: npx eslint . --max-warnings 0     # warnings are errors in CI
```

`--max-warnings 0` stops warning-creep: anything worth flagging is worth
failing the build over, or it shouldn't be enabled at all.
