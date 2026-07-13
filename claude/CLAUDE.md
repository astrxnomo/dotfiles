# Global instructions

- Don't add `Co-Authored-By: Claude ...` to git commit messages.
- External integrations (Notion, Context7, Vercel, Supabase, …) always go **through Executor** (`mcp__executor__execute`), never a direct MCP or the public API. Discover tools with `tools.search`; see the `mcp-integrations` skill for the details. Notion and Supabase have 2 accounts each: `felipegiraldo` (default) and `centrodeprototipado` (only for that project) — use whichever the task specifies.
- There are personal skills in `~/.claude/skills` for recurring tasks — check them when the task's name isn't obvious from the task itself.

## Working style

- Before implementing anything non-trivial: if there's ambiguity or multiple interpretations, ask instead of silently assuming.
- Surgical changes: only touch what the task asks for; don't "improve" adjacent code or delete unrelated dead code (mention it instead).
