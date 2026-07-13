---
name: mcp-integrations
description: Use whenever the task involves an external integration connected through Executor — Notion, Context7, Supabase, Vercel, or any other MCP surfaced by mcp__executor__execute. Ensures these are always accessed through Executor instead of a direct MCP server, the public API, or the CLI.
---

All external integrations go **through Executor** (`mcp__executor__execute`), never a direct MCP server, the public API, or a CLI shortcut. Call `skills({ name: "execute" })` inside Executor first if you're unsure how to write the sandboxed code.

**Discover, don't memorize.** Connections and tool names change over time. Use `tools.search({ query: "...", namespace: "<integration>_mcp" })` (or the bare integration name, e.g. `"vercel"`) to find the exact tool path and argument shape. Any MCP added to Executor shows up here automatically — this skill does **not** keep an inventory of them.

## Accounts

Some integrations (e.g. Notion, Supabase) have more than one connected account/organization, distinguished by a `.user.<name>` suffix on the namespace (e.g. `notion_mcp.user.felipegiraldo`, `notion_mcp.user.centrodeprototipado`).

- Use the account the user tells you to use — it's the source of truth.
- If the user didn't specify and it isn't obvious, **ask before writing** (reading from the wrong account is harmless; creating/editing, migrations, deploys, or branches are not).

## Context7 (`context7_mcp`)

Two-step flow, worth remembering because it isn't obvious from the tool list:

1. `resolve_library_id({ libraryName, query })` — both required; `query` is the user's full question, improves relevance ranking.
2. `query_docs({ libraryId, query })` — use the library ID from step 1 (prefer exact name match, higher benchmark score, and version-specific IDs when the user names a version).

Use it when the user asks about libraries, frameworks, or API references, or needs current code examples instead of relying on training data.
