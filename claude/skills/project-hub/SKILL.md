---
name: project-hub
description: Use when the work involves managing the user's projects or tasks in their Notion "Project Hub" — breaking a plan into tasks, creating/moving tasks for a project, reviewing what's pending and continuing, logging technical decisions, or registering a repo as a project. Central system shared across all repos.
---

The user's central project-management system in Notion. Lives in the **`felipegiraldo`** workspace — always access it via **Executor** (`tools.notion_mcp.user.felipegiraldo.*` inside `mcp__executor__execute`; see the `notion-mcp` skill), never the public API or scraping.

## Structure (resolve it, don't hardcode it)

IDs and schemas can drift (pages get moved, properties renamed, options added)
— always resolve them live via search/fetch, never from a remembered ID.

- **Root page "🗂️ Project Hub"** — find it with
  `notion_search({ query: "Project Hub" })`. `notion_fetch` it to list its
  child databases (`Áreas`, `Proyectos`, `Tareas`) and get their current
  `data_source_id`.
- **`Áreas` DB** — which area each project belongs to (each row links to that
  area's real hub page). Rows include `Personal`, `Centro Prototipado`.
  Property: `Área` (title).
- **`Proyectos` DB** — context and status of each project. Properties:
  `Project name` (title), `Status` (Backlog/Planning/In progress/Paused/Done/Cancelled),
  `Área` (relation → Áreas), `Dates`, `Tareas` (relation → Tareas). The **page
  body** of each project carries: summary/goal, tech stack, **Decisiones**
  (dated changelog), Links (repo, deploy).
- **`Tareas` DB (Kanban)** — properties: `Task name` (title), `Etapa` (select:
  Backlog/Ready/In progress/Done — **this is the Kanban grouping property**),
  `Proyecto` (relation → Proyectos), `Prioridad` (Alta/Media/Baja),
  `Criterios de aceptacion` (text). Board view: `Kanban` (grouped by `Etapa`).

Before writing to any of these databases, fetch the data source to confirm
its current schema and option values — property names and options can change
independently of this skill.

## Workflow

- **Starting a project → plan → tasks**: when the user gives a goal, generate the plan first (use `superpowers:brainstorming` and friends). From the plan, create **one task per verifiable step/deliverable** in the Tareas DB, with `Proyecto` pointing to the project's row, initial `Etapa` of `Backlog` or `Ready`, and concrete `Criterios de aceptacion`. Don't create tasks for trivial steps of the same atomic change.
- **Reviewing and continuing**: when the user says "check what's pending" or similar, query the Tareas DB filtered by `Proyecto`, group by `Etapa`, and continue from whatever is `In progress` / `Ready`. The user may also write a new requirement directly in Notion (a task or a note on the project page) — treat that as a source of pending work.
- **Moving a task**: when starting it, `Etapa` → `In progress`. When finishing it (change verified or PR merged), `Etapa` → `Done`.
- **Logging decisions**: for a non-obvious technical decision (library, architecture, tradeoff), add a dated line (`YYYY-MM-DD`) to the "Decisiones" section of the project page. Don't log trivial changes.

## Registering a new project

Only when the user explicitly asks:

1. Create a page in the Proyectos data source (`Project name` = repo name, `Status` = `Planning` or `In progress`, `Área` as appropriate).
2. Write in the body: Summary, Tech stack, a "Decisiones" section, Links (repo, deploy).
3. Add a line to the repo's `CLAUDE.md` with that page's ID so Claude knows which project it belongs to without asking:

   ```
   Project in Project Hub (Notion): <page_id>
   ```
