---
name: project-hub
description: Use cuando el trabajo implique gestionar proyectos o tareas del usuario en su "Project Hub" de Notion — desglosar un plan en tareas, crear/mover tareas de un proyecto, revisar qué hay pendiente y continuar, registrar decisiones técnicas, o dar de alta un repo como proyecto. Sistema central compartido entre todos los repos.
---

Sistema central de gestión de proyectos del usuario en Notion. Usa siempre el MCP de Notion (ver skill `notion-mcp`) para leer/escribir aquí — nunca la API pública ni scraping.

## Estructura (IDs fijos)

- **Página raíz "🗂️ Project Hub"**: `39623bce-2002-8127-9fba-cd7f2010ddbc`
- **BD `Áreas`** (a qué pertenece cada proyecto; cada fila enlaza a su página-hub real):
  - data_source_id: `6a900b74-a367-466a-809d-9dd724bf6197`
  - Filas: `Personal`, `Centro Prototipado`. Propiedad: `Área` (title).
- **BD `Proyectos`** (contexto y estado de cada proyecto):
  - data_source_id: `0a0e4792-4f66-422e-875e-146a3cb06987`
  - Propiedades: `Project name` (title), `Status` (Backlog/Planning/In progress/Paused/Done/Cancelled), `Área` (relación → Áreas), `Dates` (fecha del proyecto), `Tareas` (relación → Tareas)
  - El **cuerpo de la página** de cada proyecto lleva: Resumen/objetivo, Stack técnico, **Decisiones** (log cronológico fechado), Enlaces (repo, deploy).
- **BD `Tareas`** (Kanban):
  - data_source_id: `1d5f2fde-e3d5-49f2-a5aa-ad72b76a6982`
  - Propiedades: `Task name` (title), `Etapa` (select: Backlog/Ready/In progress/Done — **esta es la propiedad del Kanban**), `Proyecto` (relación → Proyectos), `Prioridad` (Alta/Media/Baja), `Criterios de aceptacion` (texto)
  - Vista tablero: `Kanban` (agrupada por `Etapa`).

## Flujo de trabajo

- **Arrancar un proyecto → plan → tareas**: cuando el usuario dé un objetivo, primero genera el plan (usa `superpowers:brainstorming` y demás). Del plan, crea **una tarea por cada paso/entregable verificable** en la BD Tareas, con `Proyecto` apuntando a la fila del proyecto, `Etapa` inicial `Backlog` o `Ready`, y `Criterios de aceptacion` concretos. No crees tareas para pasos triviales de un mismo cambio atómico.
- **Revisar y continuar**: cuando el usuario diga "mira qué hay pendiente" o similar, consulta la BD Tareas filtrando por `Proyecto`, agrupa por `Etapa`, y sigue por lo que esté en `In progress` / `Ready`. El usuario también puede escribir un requerimiento nuevo directamente en Notion (tarea o nota en la página del proyecto) — trátalo como fuente de trabajo pendiente.
- **Mover una tarea**: al empezarla, `Etapa` → `In progress`. Al terminarla (cambio verificado o PR mergeado), `Etapa` → `Done`.
- **Registrar decisiones**: ante una decisión técnica no obvia (librería, arquitectura, tradeoff), añade una línea fechada (`YYYY-MM-DD`) a la sección "Decisiones" de la página del proyecto. No registres cambios triviales.

## Registrar un proyecto nuevo

Solo cuando el usuario lo pida explícitamente:

1. Crea una página en la data source de Proyectos (`Project name` = nombre del repo, `Status` = `Planning` o `In progress`, `Área` según corresponda).
2. Escribe en el cuerpo: Resumen, Stack técnico, sección "Decisiones", Enlaces (repo, deploy).
3. Añade al `CLAUDE.md` del repo una línea con el ID de esa página para que Claude sepa a qué proyecto pertenece sin preguntar:

   ```
   Proyecto en Project Hub (Notion): <page_id>
   ```
