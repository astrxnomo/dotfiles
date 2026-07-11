# dotfiles

Personal configuration files, symlinked from here to keep them in sync across machines.

## Contents

- `wezterm/.wezterm.lua` — WezTerm terminal config (theme, keybindings, panes, tab bar)
- `oh-my-posh/material.omp.json` — Oh My Posh prompt theme (Material, tweaked)
- `powershell/Microsoft.PowerShell_profile.ps1` — PowerShell profile (Oh My Posh init + Linux-style aliases)
- `claude/settings.json` — global Claude Code settings (model, hooks, plugins, skillOverrides)
- `claude/CLAUDE.md` — global Claude Code instructions (commit rules, pointer to personal skills)
- `claude/skills/` — personal Claude Code skills (see the opt-in model below)
- `zed/settings.json` — Zed editor settings (theme, fonts, LSP, agent)
- `zed/extensions.md` — reference list of installed extensions (manual install, see note below)

### Personal skills

- `commit-and-push` — git add + version bump + commit + push
- `fix-build` — fix the build and linting errors
- `context7` — up-to-date library docs via Context7 (through Executor)
- `notion-mcp` — Notion through Executor (2 workspaces: `felipegiraldo` and `centrodeprototipado`)
- `project-hub` — manage projects/tasks in the Notion "Project Hub" (workspace `felipegiraldo`)
- `browser-verify` — test a feature with Claude in Chrome
- `felipego-projects` — publish/update felipego.com portfolio projects in Notion

Check each skill's `SKILL.md` for the current, authoritative on/off state and
scope — the list above is descriptive, not the source of truth; `claude/settings.json`'s `skillOverrides` is.

#### Opt-in model (per-project enablement)

All skills live globally (symlinked, synced), but the global default is **lean**: only the universal ones stay ON. Situational/single-project skills are OFF by default via `skillOverrides` in `claude/settings.json` and get turned on **per project** in that repo's own `.claude/settings.json` (project config overrides the global one).

To enable one in a project, in its `.claude/settings.json`:

```json
{ "skillOverrides": { "felipego-projects": "on" } }
```

## Zed

`settings.json` is symlinked from `%APPDATA%\Zed`. Extensions can't be
symlinked (Zed has no CLI or declarative file to install them);
`zed/extensions.md` is just a manual reference list for installing them by
hand from the editor (`Ctrl+Shift+X` or the `zed: extensions` command palette).

## MCP and plugins

- **MCP:** all external integrations (Notion, Context7, Vercel) are accessed via **Executor** (`mcp__executor__execute`), a single MCP server hosted at executor.sh that centralizes connections and supports multiple accounts per integration (2 Notion workspaces, 2 Vercel accounts, etc.). Connections themselves are managed in the Executor dashboard, not in this repo. The `executor` server lives in `~/.claude.json` (not symlinkable) — `install.ps1` registers it with `claude mcp add`; the first time, authorize it with `/mcp`.
- **Plugins:** only **`superpowers`** is used. Plugins don't live in the repo (they're installed from the Claude Code store); `install.ps1` runs `claude plugin install superpowers@claude-plugins-official`.
- **Cleanup:** at the end, `install.ps1` leaves Claude on this exact baseline. It detects whatever's extra on the other PC (plugins ≠ superpowers, MCP ≠ executor, loose skills in `~/.claude/skills`, and unmanaged `rules`/`settings.local.json`), shows the plan, and asks for **one single confirmation** (default No) before deleting. If there's nothing outside the baseline, it doesn't ask.

## Installing on a new PC

1. Install WezTerm, [Oh My Posh](https://ohmyposh.dev) (`winget install JanDeDobbeleer.OhMyPosh`), a Nerd Font (JetBrainsMono Nerd Font), Claude Code, and [Zed](https://zed.dev).
2. Enable **Developer Mode** (Settings > Privacy & security > For developers) so symlinks can be created without admin.
3. Clone this repo and run:

   ```powershell
   git clone https://github.com/astrxnomo/dotfiles.git D:\Code\dotfiles
   D:\Code\dotfiles\install.ps1
   ```

4. Restart WezTerm / open a new PowerShell tab.
5. Open Claude Code and run `/mcp` to authorize Executor (Notion, Context7, Vercel connections).
6. Open Zed and install the extensions listed in `zed/extensions.md` by hand.
