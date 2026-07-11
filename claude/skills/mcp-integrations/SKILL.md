---
name: mcp-integrations
description: Use whenever the task involves an external integration connected through Executor — Notion, Context7, Supabase, Vercel, or any other MCP surfaced by mcp__executor__execute. Ensures these are always accessed through Executor instead of a direct MCP server, the public API, or the CLI.
---

All external integrations go **through Executor** (`mcp__executor__execute`), never a direct MCP server, the public API, or a CLI shortcut. Call `skills({ name: "execute" })` inside Executor first if you're unsure how to write the sandboxed code.

Connections and tool names can change — use `tools.search({ query: "...", namespace: "<integration>_mcp" })` (or just the bare integration name, e.g. `"vercel"`) to discover the exact tool path and argument shape if you don't remember it. Don't hardcode assumptions beyond what's below.

## Notion (`notion_mcp`)

Two workspaces:

- `notion_mcp.user.felipegiraldo` — Felipe Giraldo's personal workspace. Default for `project-hub`, `felipego-projects`, and anything that doesn't say otherwise.
- `notion_mcp.user.centrodeprototipado` — Centro de Prototipado workspace. Only for tasks explicitly about that project/organization.

If it isn't obvious which applies, ask before writing (reading from the wrong one is harmless, creating/editing isn't).

Typical tools: `notion_search`, `notion_fetch`, `notion_create_pages`, `notion_update_page`, `notion_move_pages`.

## Supabase (`supabase_mcp`)

Two organizations:

- `supabase_mcp.user.felipegiraldo` — Felipe Giraldo's personal organization. Default.
- `supabase_mcp.user.centrodeprototipado` — Centro de Prototipado organization. Only for tasks explicitly about that project/organization.

If it isn't obvious which applies, ask before writing (reading is harmless, migrations/deploys/branches in the wrong organization aren't).

Typical tools: `list_projects`, `list_tables`, `list_branches`, `create_branch`, `deploy_edge_function`, `get_edge_function`, `list_edge_functions`, `get_advisors`, `get_logs`, `search_docs`.

## Context7 (`context7_mcp`)

Single connection: `context7_mcp.user.context7`. Use when the user asks about libraries, frameworks, API references, or needs current code examples instead of relying on training data.

Two-step flow:

1. `resolve_library_id({ libraryName, query })` — both required; `query` is the user's full question, improves relevance ranking.
2. `query_docs({ libraryId, query })` — use the library ID picked from step 1 (prefer exact name match, higher benchmark score, and version-specific IDs when the user names a version).

## Vercel (`vercel`)

Single connection: `vercel.user.felipegiraldo`. No account ambiguity — just look up the right tool with `tools.search({ query: "...", namespace: "vercel" })`.
