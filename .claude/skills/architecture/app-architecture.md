# Application architecture — layers, boundaries, evolution

## The dependency rule (the one rule that matters)

Source dependencies point **inward**: UI/transport → application → domain.
The domain knows nothing about HTTP, ORMs, or frameworks.

```
apps/api/src/
├── domain/            # entities, value objects, domain services, PORTS
│   ├── order.ts               # pure: no imports from outer layers, ever
│   └── ports.ts               # OrderRepository, PaymentGateway, Clock…
├── application/       # use-cases: orchestrate domain via ports
│   └── place-order.ts         # imports domain only
├── infrastructure/    # ADAPTERS: implement ports with real tech
│   ├── typeorm-order-repo.ts  # imports domain + the ORM
│   └── stripe-gateway.ts
└── interface/         # transport: controllers/resolvers/CLI — thin
    └── orders.controller.ts   # maps HTTP ⇄ use-case DTOs, nothing else
```

Enforce it mechanically, not by discipline:

```jsonc
// eslint — domain may not import outward
{
  "rules": {
    "no-restricted-imports": ["error", {
      "patterns": [
        { "group": ["**/infrastructure/*", "**/interface/*", "typeorm", "@nestjs/*"],
          "message": "domain/ must stay framework-free" }
      ]
    }]
  }
}
```

## Vertical slices: organize by feature, not by kind

```
# ☠ layer-first: one feature = edits in 4 distant folders
src/controllers/  src/services/  src/repositories/  src/dtos/

# ✔ feature-first: what changes together lives together
src/features/
├── orders/     # controller + use-cases + domain + adapters for orders
├── billing/
└── shared/     # truly cross-cutting only (auth context, money type)
```

Inside each slice, the dependency rule still applies. `shared/` is a
guarded exception, not a dumping ground — anything two slices need gets
promoted deliberately.

## Boundaries between modules/services

- A module's contract = exported types + functions; internals are
  unreachable (Nest `exports`, package.json `exports` field, or lint
  boundaries).
- Modules talk via **interfaces or events**, never by reaching into each
  other's tables. Two modules sharing a DB table are one module in denial.
- Sync call vs event: use an event when the caller doesn't need the result
  to proceed (order placed → email sent); use a call when it does.
  Events decouple deploys but cost traceability — pick per interaction,
  and log correlation ids either way.

## State, data, and the read/write split

- Push state to the edges: core logic takes values in, returns values out.
  A function that computes *and* saves is harder to test than
  `compute()` + `save(result)`.
- When read shapes diverge hard from write shapes (dashboards vs
  transactions), split the models (lightweight CQRS: query handlers reading
  optimized views) — without event sourcing unless there's a real audit
  requirement.

## When to split into services (and when not)

Default is the **modular monolith**: one deployable, hard internal
boundaries. Split a module into a service only on concrete pressure:
independent scaling profile, independent deploy cadence blocking teams,
different runtime/language needs, or fault-isolation requirements. A
network boundary makes every call slower, partial-failure-prone, and
harder to refactor — the module boundary must already be clean *before*
the split, or you get a distributed big ball of mud.

## Documenting decisions

Every significant choice (queue vs cron, monolith vs split, CQRS adoption)
gets a half-page ADR (`docs/adr/`, template in the docs track): context →
decision → consequences. The next agent shouldn't have to reverse-engineer
why the architecture looks like this.
