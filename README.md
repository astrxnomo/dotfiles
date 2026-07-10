# dotfiles

Archivos de configuración personal, symlinkeados desde aquí para mantenerlos sincronizados entre máquinas.

## Contenido

- `wezterm/.wezterm.lua` — config de la terminal WezTerm (tema, atajos, paneles, tab bar)
- `oh-my-posh/material.omp.json` — tema del prompt Oh My Posh (Material, ajustado)
- `powershell/Microsoft.PowerShell_profile.ps1` — perfil de PowerShell (init de Oh My Posh + alias estilo Linux)
- `claude/settings.json` — settings globales de Claude Code (modelo, hooks, plugins, skillOverrides)
- `claude/CLAUDE.md` — instrucciones globales de Claude Code (reglas de commits, puntero a skills personales)
- `claude/skills/` — skills personales de Claude Code (ver modelo opt-in abajo)

### Skills personales

- `commit-and-push` — git add + bump de versión + commit + push
- `fix-build` — arreglar build y errores de linting
- `context7-mcp` — docs actualizadas de librerías vía Context7 (por Executor)
- `notion-mcp` — Notion vía Executor (2 workspaces: `felipegiraldo` y `centrodeprototipado`)
- `project-hub` — gestión de proyectos/tareas en el "Project Hub" de Notion (workspace `felipegiraldo`)
- `browser-verify` — testear una feature con Claude in Chrome o Playwright
- `challenge-my-plan` — interrogar un plan/decisión hasta resolver toda ambigüedad
- `docker-dev-compose` — guidelines para un docker compose de desarrollo
- `webapp-blueprint` — blueprint de referencia para apps web (auth, dashboard, CRUD)
- `felipego-projects` — publicar/actualizar proyectos del portafolio felipego.com en Notion

#### Modelo opt-in (habilitación por proyecto)

Todas las skills viven globalmente (symlinkeadas, sincronizadas), pero el default global es **lean**: solo las universales quedan ON. Las situacionales/de-un-solo-proyecto quedan OFF por defecto vía `skillOverrides` en `claude/settings.json` y se activan **por proyecto** en el `.claude/settings.json` del repo que las necesite (la config de proyecto sobrescribe la global).

- **ON global (universales):** `commit-and-push`, `fix-build`, `context7-mcp`, `notion-mcp`, `project-hub`.
- **OFF global (opt-in por proyecto):** `browser-verify`, `challenge-my-plan`, `docker-dev-compose`, `webapp-blueprint`, `felipego-projects`.

Para activar una en un proyecto, en su `.claude/settings.json`:

```json
{ "skillOverrides": { "webapp-blueprint": "on" } }
```

## MCP y plugins

- **MCP:** todas las integraciones externas (Notion, Context7, Vercel) se acceden vía **Executor** (`mcp__executor__execute`), un único servidor MCP hosteado en executor.sh que centraliza las conexiones y permite múltiples cuentas por integración (2 workspaces de Notion, 2 cuentas de Vercel, etc.). Las conexiones se gestionan en el dashboard de Executor, no en este repo. El servidor `executor` vive en `~/.claude.json` (no symlinkable) — `install.ps1` lo registra con `claude mcp add`; la primera vez se autoriza con `/mcp`.
- **Plugins:** solo se usa **`superpowers`**. Los plugins no viven en el repo (se instalan en el store de Claude Code); `install.ps1` corre `claude plugin install superpowers@claude-plugins-official`.
- **Limpieza:** al final, `install.ps1` deja Claude en este baseline exacto. Detecta lo que sobra en la otra PC (plugins ≠ superpowers, MCP ≠ executor, skills sueltas en `~/.claude/skills`, y `rules`/`settings.local.json` no gestionados), muestra el plan y pide **una sola confirmación** (default No) antes de borrar. Si no hay nada fuera del baseline, no pregunta.

## Instalación en una PC nueva

1. Instala WezTerm, [Oh My Posh](https://ohmyposh.dev) (`winget install JanDeDobbeleer.OhMyPosh`), una Nerd Font (JetBrainsMono Nerd Font) y Claude Code.
2. Activa el **Modo de desarrollador** (Configuración > Privacidad y seguridad > Para desarrolladores) para que se puedan crear symlinks sin admin.
3. Clona este repo y ejecuta:

   ```powershell
   git clone https://github.com/astrxnomo/dotfiles.git D:\Code\dotfiles
   D:\Code\dotfiles\install.ps1
   ```

4. Reinicia WezTerm / abre una pestaña nueva de PowerShell.
5. Abre Claude Code y ejecuta `/mcp` para autorizar Executor (conexiones de Notion, Context7, Vercel).
