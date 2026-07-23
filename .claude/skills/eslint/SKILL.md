---
name: eslint
description: >-
  Modern ESLint (v9/v10 baseline) — flat config only, typescript-eslint typed
  linting, framework plugins, and the ESLint MCP server so agents lint through
  a real tool instead of guessing. Use when setting up or migrating ESLint,
  editing eslint.config.*, fixing lint errors, choosing rules, or wiring
  lint checks into agents and CI.
---

# ESLint (flat config + MCP, v10 baseline)

References:

- [flat-config.md](flat-config.md) — `eslint.config.js` recipes: base JS,
  typed TypeScript, Angular, NestJS/Node, Prettier interplay
- [mcp-server.md](mcp-server.md) — the ESLint MCP server: registration and
  the agent lint-fix loop

## Modern baseline (v10, 2026)

- **Flat config is the only format.** `eslint.config.js|mjs|ts` with
  `defineConfig()` from `"eslint/config"`. `.eslintrc*` support is
  **removed** in v10 — migrate (`npx @eslint/migrate-config .eslintrc.json`),
  never author new eslintrc files. `.eslintignore` is gone too: use
  `globalIgnores([...])`.
- **Config lookup is file-based** (v10): ESLint finds `eslint.config.*` by
  walking up from each linted file, not from the cwd — monorepo packages can
  carry their own config without `--config` gymnastics.
- Requires Node `^20.19 || ^22.13 || >=24`.
- Presets come from packages, not strings: `js.configs.recommended` from
  `@eslint/js`, `tseslint.configs.recommendedTypeChecked` from
  `typescript-eslint`.
- **Typed linting by default** in TS projects via
  `languageOptions.parserOptions.projectService: true` — the rules that
  catch real bugs (`no-floating-promises`, `no-misused-promises`,
  `await-thenable`) need type information.
- ESLint checks **correctness**; Prettier formats. Put
  `eslint-config-prettier` last and don't enable stylistic formatting rules
  that fight the formatter.

## For agents

- **Lint through the MCP server** (registered in `.mcp.json` as `eslint`) or
  `npx eslint <files>` — never eyeball-guess whether code passes lint.
  After editing JS/TS: lint the touched files, fix, re-lint. Clean lint is
  part of "done" (§ verification standard).
- `npx eslint --fix` for mechanical fixes; read what it changed.
- Never silence a rule to get a diff through: no `eslint-disable` without a
  one-line justification comment, no downgrading `error` → `warn` in config,
  no widening ignores. If a rule is genuinely wrong for the repo, propose
  the config change to the user instead.
