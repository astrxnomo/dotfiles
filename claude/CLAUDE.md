# Global instructions

- Don't add `Co-Authored-By: Claude ...` to git commit messages.
- External integrations (Notion, Context7, Vercel, Supabase, …) always go **through Executor** (`mcp__executor__execute`), never a direct MCP or the public API. See the `mcp-integrations` skill for connection names per service (Notion and Supabase each have 2 accounts: `felipegiraldo` default, `centrodeprototipado` only for that project).
- There are personal skills in `~/.claude/skills` for recurring tasks — check them when the task's name isn't obvious from the task itself.

## Working style

- Before implementing anything non-trivial: if there's ambiguity or multiple interpretations, ask instead of silently assuming.
- Surgical changes: only touch what the task asks for; don't "improve" adjacent code or delete unrelated dead code (mention it instead).
