# Codemods & mechanical changes at scale

When the same change hits 20+ sites, stop hand-editing: script it. A codemod
is reviewable (the script *is* the spec), re-runnable, and doesn't
fat-finger site #37.

## Tool ladder (cheapest that works)

**1. LSP/IDE rename** — symbols, files. Semantics-aware; always first.

**2. Structural search** — `ast-grep`/`comby` for pattern rewrites:

```bash
# swap argument order across the repo, TS-aware
ast-grep --pattern 'oldFn($A, $B)' --rewrite 'newFn($B, $A)' --lang ts --update-all

# migrate a deprecated API with options-object
ast-grep --pattern 'createUser($NAME, $EMAIL, $ROLE)' \
         --rewrite 'createUser({ name: $NAME, email: $EMAIL, role: $ROLE })' \
         --lang ts --update-all
```

**3. jscodeshift / ts-morph** (JS/TS), **LibCST** (Python) — transforms with
logic:

```js
// codemods/default-import-to-named.js
// npx jscodeshift -t codemods/default-import-to-named.js src/ --extensions=ts,tsx
export default function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  root.find(j.ImportDeclaration, { source: { value: "old-lib" } })
    .forEach(path => {
      const def = path.node.specifiers.find(s => s.type === "ImportDefaultSpecifier");
      if (!def) return;
      path.node.specifiers = [j.importSpecifier(j.identifier("client"),
                                                j.identifier(def.local.name))];
      path.node.source = j.literal("new-lib");
    });
  return root.toSource({ quote: "double" });
}
```

**4. `sed`/regex** — only for truly textual changes (string literals,
comments). Regex on code syntax is how half-renamed identifiers happen.

## Procedure

1. Write the transform against 2-3 representative files; eyeball the diff.
2. Run repo-wide on a **clean tree**; commit the codemod script alongside
   the change in `scripts/codemods/` — it documents the migration and reruns
   on straggler branches.
3. **Sweep for stragglers** the AST tool can't see:

```bash
rg -n "oldFn|old-lib" --type-add 'all:*' -t all \
  -g '!node_modules' -g '!*.lock'
# strings, docs, configs, dynamic access obj["oldFn"], other languages
```

4. Typecheck + full test run. Then review the diff **sampled by pattern** —
   read every distinct *shape* of change once, not all 400 hunks:

```bash
git diff --stat | sort -k3 -n | tail        # biggest files first
git diff -- 'src/**/one-example-per-shape*' # one representative per pattern
```

## Deprecation etiquette

For public APIs, codemod in two releases:

```ts
/** @deprecated Use createUser(opts) — run `npx acme-codemod v3/user-opts` */
export function createUserLegacy(name: string, email: string) {
  warnOnce("createUserLegacy is deprecated; see migration guide v3");
  return createUser({ name, email });
}
```

1. Ship the new API + deprecation warning + the codemod itself.
2. Next major: codemod consumers, remove the old API.

Publishing the codemod with the release notes (React/Next.js style) is the
difference between a migration and a breaking change.
