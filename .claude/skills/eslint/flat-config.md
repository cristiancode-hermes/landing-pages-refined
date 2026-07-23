# Flat config recipes (main blueprint: web/backend TS)

All recipes are ESM `eslint.config.mjs`, ESLint v10, `defineConfig` from
`"eslint/config"`. Compose: ignores → base JS → typed TS → framework layer →
prettier **last**.

## Base: JS + typed TypeScript

```js
// eslint.config.mjs
import { defineConfig, globalIgnores } from "eslint/config";
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import globals from "globals";
import prettier from "eslint-config-prettier";

export default defineConfig([
  globalIgnores(["dist/", "coverage/", "**/*.gen.ts"]),

  { files: ["**/*.{js,mjs}"], ...js.configs.recommended },

  {
    files: ["**/*.ts"],
    extends: [...tseslint.configs.recommendedTypeChecked],
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
    rules: {
      // aligned with the house style (architecture/angular tracks):
      "@typescript-eslint/explicit-member-accessibility": ["error", { accessibility: "no-public" }],
      "@typescript-eslint/prefer-readonly": "error",
      "prefer-const": "error",
      "no-var": "error",
      "no-param-reassign": "error",
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
    },
  },

  prettier, // last: turns off anything that fights the formatter
]);
```

- `projectService: true` replaces the old `project: ["./tsconfig.json"]`
  dance — typed rules work per-file with no path lists.
- `no-floating-promises` / `no-misused-promises` are the highest-value typed
  rules: they catch unawaited work that "passes" at runtime until it doesn't.

## Angular layer (angular-eslint)

```bash
ng add angular-eslint          # wires configs + templates in an Angular CLI repo
```

```js
import angular from "angular-eslint";

export default defineConfig([
  // …base layers…
  {
    files: ["**/*.ts"],
    extends: [...angular.configs.tsRecommended],
    processor: angular.processInlineTemplates,
    rules: {
      "@angular-eslint/prefer-standalone": "error",
      "@angular-eslint/prefer-signals": "error",          // signal-first house style
      "@angular-eslint/prefer-inject": "error",           // inject() over constructor DI
      "@angular-eslint/directive-selector": ["error", { type: "attribute", prefix: "app", style: "camelCase" }],
      "@angular-eslint/component-selector": ["error", { type: "element", prefix: "app", style: "kebab-case" }],
    },
  },
  {
    files: ["**/*.html"],
    extends: [...angular.configs.templateRecommended, ...angular.configs.templateAccessibility],
  },
]);
```

The template-accessibility configs are non-negotiable in this kit — they're
the lint arm of the frontend/a11y track.

## NestJS / Node backend layer

```js
export default defineConfig([
  // …base layers…
  {
    files: ["apps/api/**/*.ts"],
    languageOptions: { globals: { ...globals.node } },
    rules: {
      "@typescript-eslint/no-extraneous-class": "off",   // Nest modules are decorated classes
      "@typescript-eslint/explicit-function-return-type": ["error", { allowExpressions: true }],
    },
  },
]);
```

## Monorepo note

v10 looks up `eslint.config.*` from each **file's** directory upward — each
package can own a config that extends a shared root export; no `--config`
flags in scripts.

## Migrating a repo that still has `.eslintrc*`

```bash
npx @eslint/migrate-config .eslintrc.json   # generates eslint.config.mjs
```

Then delete `.eslintrc*` and `.eslintignore` (v10 ignores them at best,
errors at worst), move ignore globs into `globalIgnores()`, and re-run the
full lint to see what the preset drift surfaced.
