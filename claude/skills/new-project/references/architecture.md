# Architecture

## The question that decides everything

Juniors ask "where should I put this file?". The better question is **"who should be allowed to know about this?"**

Once a codebase grows, folders stop being the problem and ownership becomes it. The UI should not know Stripe price IDs. The API should not own business logic. The database should not leak into the frontend. Every layer has one job, and code is organized by **responsibility**, not by file type.

A good codebase does not just tell you where files are. It tells you where decisions belong.

## The layers

Six layers, one direction of dependency:

| Layer | Knows about | Job |
|---|---|---|
| **UI** | User intent | Routes, screens, components. Expresses what the user did. |
| **Transport** | Requests | Validates input, checks authentication and permissions, delegates. Owns the typed client. |
| **Domain** | The product | Business decisions. This is where the truth of the product lives. |
| **Capabilities** | Integration shape | Stable facades over payments, storage, email, analytics. Provider-agnostic. |
| **Vendors** | One external system | Stripe, S3, Resend, the auth provider. Lives at the edge. |
| **Supporting foundations** | Contracts and persistence | Shared schemas and types, database client. |

### The dependency rule

**Each layer may only reach the layer below it.**

```
UI → Transport → Domain → Capabilities → Vendors
                                ↑
              Supporting foundations (shared, database)
```

- The UI calls Transport. It does **not** call Domain, and it certainly does not call a vendor.
- Transport calls Domain. Domain never calls back up into Transport or UI.
- Domain calls Capabilities. Capabilities call Vendors.
- **One exception**: supporting foundations flow upward. `shared` (contracts, schemas) and `database` can be imported by any layer, because they define the vocabulary everyone speaks.

The payoff is not aesthetic. It is that a whole class of mistake becomes structurally impossible: no call from the UI straight to Stripe, no authorization enforced in the browser. Agents love shortcuts; the dependency rule removes the shortcut rather than asking politely.

### A request, end to end

A user subscribes to a plan:

1. **UI**: the plan CTA fires. It knows a button was clicked, nothing more.
2. **Transport**: validates the input, confirms the session, checks permissions, delegates.
3. **Domain**: `createCheckoutForOrg` decides whether this organization is eligible. The business rule lives here and only here.
4. **Capability**: `createCheckoutSession`, provider-agnostic.
5. **Vendor**: the actual Stripe call.

Swapping Stripe for something else touches layer 5 and maybe 4. Nothing above notices.

## Folder structure

### Single app profile (default)

Layers are folders, and the boundary is enforced by lint rules rather than package graphs.

```
├── app/                      # routes and layouts only
│   ├── (marketing)/
│   ├── (app)/
│   └── api/
├── components/
│   ├── ui/                   # design system primitives, CLI-owned
│   └── <feature>/            # product-specific composites
├── data/                     # the data layer, one folder per module
│   ├── user/
│   │   └── require-user.ts
│   └── <module>/
│       ├── <module>.dto.ts
│       ├── <module>.policy.ts
│       ├── <module>.dal.ts
│       └── <module>.actions.ts
├── lib/                      # genuinely shared utilities
├── hooks/
├── AGENTS.md
└── CLAUDE.md                 # points at AGENTS.md
```

`data/` is the compressed version of Transport + Domain + Foundations. That compression is the point of the single-app profile: same principles, less ceremony. Split it into packages when the project actually earns it.

> **VERIFY:** whether the framework wants this data folder inside or beside the routes directory, and whether it has a private-folder convention (a prefix that keeps a directory from becoming a route) you should be using. Look up the current routing and colocation conventions.

### Monorepo profile

One package per layer, so the dependency rule is enforced by the package graph itself.

```
├── apps/
│   ├── web/                  # UI layer, the deployable
│   └── docs/
├── packages/
│   ├── api/                  # transport
│   ├── core/                 # domain
│   ├── database/             # schema and migrations
│   ├── shared/               # contracts, schemas, types
│   ├── payments/             # capability + its vendor
│   ├── email/
│   ├── analytics/
│   └── brand/                # design system
├── turbo.json
├── AGENTS.md
└── package.json
```

Read the dependency rule straight off each package's manifest: `web` depends on `api` but never on `core`; `api` depends on `core` but never on `web`; `core` depends on capabilities but never on vendors or transport. If a manifest violates the diagram, the architecture is already broken.

> **VERIFY:** current monorepo tooling setup, workspace configuration syntax, and task pipeline config. Look up the build orchestrator's current config format.

Two details worth carrying over:

- **Lock down install scripts.** Only dependencies that genuinely need it should be allowed to run postinstall code. Everything else is blocked by default.
- **The task pipeline encodes real dependencies.** If type checking needs generated ORM types, declare that, so types are never stale.

## Naming

Pick one file naming format and never deviate. Which one matters far less than the consistency.

- **kebab-case** for source files: components, hooks, schemas, tests, all of it.
- Convention-mandated names are the exception and stay as the ecosystem defines them: `README.md`, `AGENTS.md`, `CLAUDE.md`, framework-reserved file names.
- **snake_case** in the database, always. Never carry JavaScript camelCase into SQL.

Mixing formats is the single most common junior tell, and it is also what language models do by default when a codebase gives them no signal. Consistency means neither a new engineer nor an agent ever has to guess what a file is called.

## Enforcing the boundaries

Documentation is a suggestion. Lint rules are a boundary.

Use import-restriction rules so that a violation is a lint error, and have CI run them so a violation cannot deploy. Example intent: the web app may import the payments **client** entry point, and nothing else from payments; server internals, types, and catalog are off limits from the UI layer.

This buys you **fast failure**. Without it, an agent writes 80% of a feature before discovering it imported the wrong thing. With it, the error appears at the first bad import.

Server boundaries deserve their own rules. A webhook route runs on the server, which does not mean everything server-side belongs there.

> **VERIFY:** current linter config format and the exact rule name for import restrictions. Flat config and rule names have both moved recently. Look it up rather than writing config from memory.

## `AGENTS.md`

Lives at the repo root. It is the file coding agents look for, so it holds the conventions in the form they will actually read.

Contents:

- The dependency rule, stated plainly, with the illegal imports named.
- File naming convention.
- Where a new feature goes: which files to create, in which order.
- The resolved stack versions.
- Guardrails: what never happens (ORM calls in a page, authorization in the client, literal colors in components).

`CLAUDE.md` should point at `AGENTS.md` rather than duplicating it. Two copies of the conventions means one of them is stale.

> **VERIFY:** some frameworks now ship their own documentation inside the installed package for agents to read locally. If yours does, point `AGENTS.md` at that path. Look up whether the framework ships bundled agent docs, and where.
