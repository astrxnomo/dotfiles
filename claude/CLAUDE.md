# Instrucciones globales

- No añadir `Co-Authored-By: Claude ...` en los mensajes de commit de git.
- Las integraciones externas (Notion, Context7, Vercel, …) van **siempre por Executor** (`mcp__executor__execute`), nunca por un MCP directo ni la API pública. Notion tiene 2 workspaces: `felipegiraldo` (default) y `centrodeprototipado` (solo para ese proyecto). Ver skills `notion-mcp` y `context7-mcp`.
- Hay skills personales en `~/.claude/skills` para tareas recurrentes — revísalas cuando el nombre no sea obvio a partir de la tarea.

## Estilo de trabajo

- Antes de implementar algo no trivial: si hay ambigüedad o varias interpretaciones, pregunta en vez de asumir en silencio.
- Cambios quirúrgicos: toca solo lo que pide la tarea; no "mejores" código adyacente ni borres código muerto ajeno (menciónalo).
