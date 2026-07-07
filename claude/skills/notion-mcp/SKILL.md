---
name: notion-mcp
description: Use whenever the task involves reading, creating, or editing content in Notion (pages, databases, comments). Ensures Notion is always accessed through the Notion MCP server instead of scraping, the public API directly, or other workarounds.
---

Para cualquier operación sobre Notion (leer/crear/editar páginas o databases, comentarios, búsquedas), usa siempre el servidor MCP de Notion (`notion`), nunca un fetch directo a la API pública ni scraping del sitio.

Si el MCP de Notion no está conectado en el proyecto actual, agrégalo antes de continuar:

```
claude mcp add --transport http notion https://mcp.notion.com/mcp --scope user
```

La primera vez pedirá autenticación OAuth en el navegador.
