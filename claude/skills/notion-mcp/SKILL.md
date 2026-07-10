---
name: notion-mcp
description: Use whenever the task involves reading, creating, or editing content in Notion (pages, databases, comments). Ensures Notion is always accessed through the Notion MCP server instead of scraping, the public API directly, or other workarounds.
---

Para cualquier operación sobre Notion (leer/crear/editar páginas o databases, comentarios, búsquedas), usa siempre Notion vía **Executor** (`mcp__executor__execute`), nunca un fetch directo a la API pública ni scraping del sitio. Ya no existe un servidor MCP de Notion directo — se quitó de `~/.claude.json` en favor de Executor.

## Cuentas disponibles

Hay dos conexiones de Notion en Executor, cada una un workspace distinto:

- `notion_mcp.user.felipegiraldo` — workspace personal de Felipe Giraldo. Úsala para `project-hub`, `felipego-projects`, y cualquier tarea que no especifique lo contrario.
- `notion_mcp.user.centrodeprototipado` — workspace de Centro de Prototipado. Úsala solo cuando la tarea sea explícitamente sobre ese proyecto/organización.

Si no es obvio por contexto cuál de las dos aplica, pregunta antes de escribir nada (leer de la equivocada es inofensivo, pero crear/editar en el workspace equivocado no).

## Cómo llamarlo

Dentro de `mcp__executor__execute`:

```ts
const result = await tools.notion_mcp.user.felipegiraldo.notion_search({
  query: "<búsqueda>",
  query_type: "internal",
  page_size: 5,
});
return result;
```

Herramientas típicas: `notion_search`, `notion_fetch`, `notion_create_pages`, `notion_update_page`, `notion_move_pages`. Usa `tools.search({ query: "...", namespace: "notion_mcp" })` para descubrir el nombre exacto y el shape de argumentos si no lo recuerdas.
