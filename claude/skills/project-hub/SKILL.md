---
name: project-hub
description: Use cuando el trabajo implique gestionar proyectos o tareas del usuario en su "Project Hub" de Notion — crear/mover tareas de un proyecto, desglosar un plan en tareas, registrar decisiones técnicas, reportar avance, o dar de alta un repo como proyecto. Sistema central compartido entre todos los repos.
---

Sistema central de gestión de proyectos del usuario en Notion. Usa siempre el MCP de Notion (ver skill `notion-mcp`) para leer/escribir aquí — nunca la API pública ni scraping.

## Estructura (IDs fijos)

- **Página raíz "🗂️ Project Hub"**: `39623bce-2002-8127-9fba-cd7f2010ddbc`
- **BD `Proyectos`** (contexto y estado de cada proyecto):
  - data_source_id: `0a0e4792-4f66-422e-875e-146a3cb06987`
  - Propiedades: `Project name` (title), `Status` (status: Backlog/Planning/In progress/Paused/Done/Cancelled), `Owner` (person), `Dates` (date), `Tareas` (relación → Tareas)
  - El **cuerpo de la página** de cada proyecto lleva: Resumen/objetivo, Stack técnico, **Decisiones** (log cronológico fechado), Enlaces (repo, deploy).
- **BD `Tareas`** (Kanban):
  - data_source_id: `1d5f2fde-e3d5-49f2-a5aa-ad72b76a6982`
  - Propiedades: `Task name` (title), `Etapa` (select: Backlog/Ready/In progress/Done — **esta es la propiedad del Kanban**), `Proyecto` (relación → Proyectos), `Prioridad` (Alta/Media/Baja), `Criterios de aceptacion` (texto), `PR / Commit` (url), `Assignee` (person), `Due` (date)
  - **Ignora** la propiedad nativa `Status`: el flujo real es `Etapa`.
  - Vista tablero: `Kanban` (agrupada por `Etapa`).

## Convenciones de uso

- **Crear una tarea**: página nueva en la data source de Tareas, con `Proyecto` apuntando a la fila del proyecto, `Etapa` inicial normalmente `Backlog` o `Ready`, y `Criterios de aceptacion` si el trabajo lo amerita.
- **Mover una tarea**: al empezarla, `Etapa` → `In progress`. Al terminarla (PR mergeado o cambio verificado), `Etapa` → `Done` y rellena `PR / Commit` si aplica.
- **Desglosar un plan en tareas**: crea una tarea por cada paso/entregable verificable, con `Criterios de aceptacion` concretos. No crees tareas para pasos triviales de un mismo cambio atómico.
- **Registrar decisiones**: ante una decisión técnica no obvia (librería, arquitectura, tradeoff), añade una línea fechada (`YYYY-MM-DD`) a la sección "Decisiones" de la página del proyecto. No registres cambios triviales.
- **Reportar progreso**: consulta la BD Tareas filtrando por `Proyecto`, agrupa por `Etapa`, y resume: hecho, en curso, bloqueado, siguiente.

## Registrar un proyecto nuevo

Solo cuando el usuario lo pida explícitamente:

1. Crea una página en la data source de Proyectos (`Project name` = nombre del repo, `Status` = `Planning` o `In progress`).
2. Escribe en el cuerpo: Resumen, Stack técnico, sección "Decisiones", Enlaces (repo, deploy).
3. Añade al `CLAUDE.md` del repo una línea con el ID de esa página para que Claude sepa a qué proyecto pertenece sin preguntar:

   ```
   Proyecto en Project Hub (Notion): <page_id>
   ```
