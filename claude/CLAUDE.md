# Global instructions

- Don't add `Co-Authored-By: Claude ...` to git commit messages.
- External integrations (Notion, Context7, Vercel, Supabase, …) always go **through Executor** (`mcp__executor__execute`), never a direct MCP or the public API. Discover tools with `tools.search`; see the `mcp-integrations` skill for the details. Notion and Supabase have 2 accounts each: `felipegiraldo` (default) and `centrodeprototipado` (only for that project) — use whichever the task specifies.
- There are personal skills in `~/.claude/skills` for recurring tasks — check them when the task's name isn't obvious from the task itself.

## Working style

- Before implementing anything non-trivial: if there's ambiguity or multiple interpretations, ask instead of silently assuming.
- Surgical changes: only touch what the task asks for; don't "improve" adjacent code or delete unrelated dead code (mention it instead).

## Engineering principles

- No backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers: start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Don't reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Don't assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Don't accept a stopgap that only works for now and is meant to be replaced later.
