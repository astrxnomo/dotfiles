---
name: new-project
description: Start a new project from zero with a senior-level architecture instead of whatever the framework's CLI leaves behind. Runs a discovery pass (mini-PRD, entities, scale), verifies every version-specific detail against the live docs with Context7, presents a blueprint for approval, and only then scaffolds the folder structure, layered boundaries, data access layer, design tokens and agent guardrails. Use when asked to start/create/bootstrap/scaffold a new project or app, to set up the architecture or folder structure for something new, or when the user says things like "vamos a arrancar un proyecto nuevo", "crea la estructura", "monta el proyecto". Not for adding features to an existing codebase.
---

# New project

The first hour of a project decides whether it scales. Folders are the easy part; the hard part is **ownership**: who is allowed to know about what. A codebase where the UI can reach Stripe, or where `page.tsx` calls the ORM directly, does not get better with time. It gets bigger.

This matters more with coding agents than without them. An agent reads the conventions already in the repo and builds on top of them. Bad structure does not stay bad at constant size; it compounds. Set the boundaries first and the agent's shortcuts become impossible rather than merely discouraged.

## The reference material is principles, not versions

`references/` holds distilled architecture knowledge: layering, the dependency rule, DAL/DTO/policy, multi-layered auth, ERD design, design tokens. Those principles hold across versions.

**Every concrete API, file name, flag, and command is a moving target.** The reference files mark them with `VERIFY:` blocks stating exactly what to look up. Never scaffold from what a reference file (or your training data) *implies* the current API is. As a live example of why: Next.js renamed `middleware` to `proxy`, and now ships its own docs inside `node_modules/next/docs`. Any skill that had hardcoded those would already be wrong.

## Workflow

Create a todo per phase. Do not skip phase 3's checkpoint.

### 1. Discovery

Understand the product before touching the stack. Ask, one question at a time, only what you cannot infer:

- **What is it?** One paragraph. This becomes the mini-PRD.
- **Features in scope.** A list. Every noun in it is a candidate entity.
- **Who are the users, and does it have tenancy?** Single-user, multi-user, or multi-tenant (organizations/workspaces). This one decision reshapes the whole schema.
- **What is already decided?** Deployment target, database, auth provider, payments, anything the user already pays for or knows they want.

Then pick the **profile**, and say which one you picked and why:

| Profile | When | Shape |
|---|---|---|
| **Single app** (default) | Most projects. One deployable, one team, one product surface. | One Next.js app, layering enforced by folders and lint rules inside it. |
| **Monorepo** | Multiple deployables (web + docs + marketing), or capabilities that genuinely need to be swappable behind stable APIs (payments, storage, email across products). | Turborepo + workspaces, one package per layer. |

Do not default to the monorepo. It is the right end state for a product with real scale, and premature weight for anything smaller. The layering principles are identical in both; only the enforcement mechanism differs (folders + lint vs. package boundaries).

### 2. Version verification (Context7 through Executor)

**This phase is what makes the skill reusable.** Context7 goes through Executor (`mcp__executor__execute`), never a direct MCP. See the `mcp-integrations` skill.

Find the tool path with `tools.search({ query: "resolve library id docs", namespace: "context7_mcp" })` rather than assuming it. It is nested under an account segment and that path changes.

Two-step flow:

1. `resolve_library_id({ libraryName, query })`: both required. Pass the full question as `query`; it improves ranking. Prefer an exact name match with a high benchmark score, and a version-specific id when you know which major you are installing.
2. `query_docs({ libraryId, query })`: ask a real implementation question, not a keyword.

Read the version attached to whatever comes back. It is the difference between "the docs say X" and "the docs for the version you are about to install say X".

Resolve, at minimum:

- **The framework.** Current major version, what the CLI creates today, which conventions were renamed or removed, which config flags are needed for features you plan to use.
- **The ORM / database client.** Current schema syntax, id generation, migration commands.
- **The auth provider**, if any. Current session API and its server-side entry point.
- **The component library.** Current CLI command and init flow.

Then walk `references/` and resolve every `VERIFY:` block that applies to the chosen stack.

Record the resolved versions. They go in the blueprint and in `AGENTS.md`.

If the live docs contradict a reference file, **the docs win** and you say so out loud in the blueprint. If a reference file's *principle* no longer has a mechanism in the current version, say that too rather than inventing one.

### 3. Blueprint, then stop

Present, compactly:

1. **Mini-PRD**: the paragraph and the feature list.
2. **Entities and ERD**: tables, fields, keys, relationship types. Follow `references/database.md`. Present as a diagram or a clear list; this is the piece most worth getting right before any code exists.
3. **Folder tree**: the actual tree you will create, per `references/architecture.md` and the chosen profile.
4. **Stack and exact versions**: resolved in phase 2, plus anything Context7 corrected.
5. **What you will not do**: explicitly out of scope for this scaffold.

**Then stop and wait for approval.** Do not scaffold before the user approves. If they change the entities or the stack, revise and present again.

### 4. Scaffold

In this order, so the project works end to end at every step:

1. **Run the framework CLI** with the flags verified in phase 2. Let it create what it creates; do not fight it.
2. **Apply the folder structure** from the approved blueprint. Empty directories are fine as placeholders only if something in them is coming in this same scaffold; otherwise leave them out.
3. **Database schema** from the approved ERD, plus the initial migration. Verify it applies.
4. **Design system**: install the component library, set semantic tokens in the global stylesheet, configure dark mode. Per `references/design-system.md`.
5. **One vertical slice.** Pick a single real entity from the ERD and build it all the way through: DTO, policy, DAL, action, and a page that renders it. This is the template every future feature copies, and it is what proves the architecture actually runs. Per `references/data-layer.md`.
6. **Guardrails**: lint rules enforcing the layer boundaries, plus `AGENTS.md` at the repo root documenting conventions, the dependency rule, and the resolved versions. A `CLAUDE.md` that points at `AGENTS.md` rather than duplicating it.

### 5. Verify

Run the build and the linter. Both must pass. If the vertical slice has a page, run the dev server and confirm it renders.

Report what was created, the resolved versions, anything Context7 corrected, and what is deliberately left for later. Do not claim it works without the command output.

## Reference files

Read the ones relevant to the project. Do not read all four for a project that has no database.

| File | Covers |
|---|---|
| `references/architecture.md` | Layers, dependency rule, folder trees for both profiles, naming, boundary enforcement, `AGENTS.md` |
| `references/data-layer.md` | DAL, DTO, policy, multi-layered auth, server-only, session caching |
| `references/database.md` | PRD to entities to ERD, keys, relationships, conventions, common mistakes |
| `references/design-system.md` | Component ownership, semantic tokens, variants vs. wrappers, theming |
