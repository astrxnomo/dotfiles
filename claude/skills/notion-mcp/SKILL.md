---
name: notion-mcp
description: Use whenever the task involves reading, creating, or editing content in Notion (pages, databases, comments). Ensures Notion is always accessed through the Notion MCP server instead of scraping, the public API directly, or other workarounds.
---

For any Notion operation (reading/creating/editing pages or databases, comments, search), always go through Notion via **Executor** (`mcp__executor__execute`), never a direct fetch to the public API or site scraping. There is no direct Notion MCP server anymore — it was removed from `~/.claude.json` in favor of Executor.

## Available accounts

There are two Notion connections in Executor, each a different workspace:

- `notion_mcp.user.felipegiraldo` — Felipe Giraldo's personal workspace. Use it for `project-hub`, `felipego-projects`, and any task that doesn't say otherwise.
- `notion_mcp.user.centrodeprototipado` — Centro de Prototipado workspace. Use it only when the task is explicitly about that project/organization.

If it isn't obvious from context which of the two applies, ask before writing anything (reading from the wrong one is harmless, but creating/editing in the wrong workspace isn't).

## How to call it

Inside `mcp__executor__execute`:

```ts
const result = await tools.notion_mcp.user.felipegiraldo.notion_search({
  query: "<search query>",
  query_type: "internal",
  page_size: 5,
});
return result;
```

Typical tools: `notion_search`, `notion_fetch`, `notion_create_pages`, `notion_update_page`, `notion_move_pages`. Use `tools.search({ query: "...", namespace: "notion_mcp" })` to discover the exact name and argument shape if you don't remember it — connections and tool names can change, so don't hardcode assumptions about them.
