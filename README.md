# dotfiles

Personal config files, symlinked into place from here so they stay in sync across machines.

## Contents

- `wezterm/.wezterm.lua` — WezTerm terminal config (theme, keybindings, panes, tab bar)
- `oh-my-posh/material.omp.json` — Oh My Posh prompt theme (Material, tweaked)
- `powershell/Microsoft.PowerShell_profile.ps1` — PowerShell profile (Oh My Posh init + Linux-style aliases)
- `claude/settings.json` — Claude Code global settings (model, hooks, enabled plugins)
- `claude/CLAUDE.md` — Claude Code global instructions (reglas de commits, puntero a skills personales)
- `claude/rules/` — Claude Code global rules (Context7 usage)
- `claude/skills/` — Personal Claude Code skills:
  - `context7-mcp`, `felipego-projects` — proyecto-específicas
  - `browser-verify` — testear una feature con Claude in Chrome o Playwright
  - `fix-build` — arreglar build y errores de linting
  - `commit-and-push` — git add + bump de versión + commit + push
  - `docker-dev-compose` — guidelines para un docker compose de desarrollo
  - `challenge-my-plan` — interrogar un plan/decisión hasta resolver toda ambigüedad
  - `webapp-blueprint` — blueprint de referencia para apps web (auth, dashboard, CRUD)
  - `notion-mcp` — fuerza el uso del servidor MCP de Notion para cualquier operación en Notion

## Setup on a new PC

1. Install WezTerm, [Oh My Posh](https://ohmyposh.dev) (`winget install JanDeDobbeleer.OhMyPosh`), and a Nerd Font (JetBrainsMono Nerd Font).
2. Enable **Developer Mode** (Settings > Privacy & security > For developers) so symlinks can be created without admin.
3. Clone this repo and run:

   ```powershell
   git clone https://github.com/astrxnomo/dotfiles.git D:\Code\dotfiles
   D:\Code\dotfiles\install.ps1
   ```

4. Restart WezTerm / open a new PowerShell tab.
