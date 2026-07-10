# Run this on a new PC to link these dotfiles into place.
# Requires Developer Mode enabled (Settings > Privacy & security > For developers)
# so that New-Item -ItemType SymbolicLink works without admin.

$repo = $PSScriptRoot
$backupDir = "$env:USERPROFILE\.dotfiles-backup"

function Link-Config($target, $source) {
    $dir = Split-Path $target
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }

    $existing = Get-Item -Path $target -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType -eq "SymbolicLink") {
            # Already a link (maybe stale) — just drop it and re-create.
            Remove-Item $target -Force -Recurse
        } else {
            # A real file/dir is in the way. Back it up instead of destroying it.
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
            }
            $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $dest = Join-Path $backupDir ((Split-Path $target -Leaf) + ".$stamp")
            Move-Item -Path $target -Destination $dest -Force
            Write-Output "Backed up existing $target -> $dest"
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
    } catch {
        Write-Warning "Failed to link $target -> $source ($($_.Exception.Message))"
        return
    }

    Write-Output "Linked $target -> $source"
}

# Deja Claude Code en el baseline de dotfiles: solo el plugin superpowers, solo el
# MCP executor, y solo las skills symlinkeadas desde este repo. Calcula todo lo que
# sobra, lo muestra agrupado y pide UNA sola confirmación (default No) antes de borrar.
# No toca repos de proyecto, symlinks gestionados por dotfiles, ni conectores de
# claude.ai (Canva/Drive viven en la cuenta, no en ~/.claude.json).
function Clean-ClaudeBaseline($repo) {
    $plugins = @(); $mcp = @(); $skills = @(); $other = @()

    # 1. Plugins != superpowers (ignora los inline/harness, no desinstalables).
    foreach ($line in (claude plugin list 2>$null)) {
        if ($line -match '([\w.-]+@[\w.-]+)') {
            $id = $Matches[1]
            if ($id -notmatch '^superpowers@' -and $id -notmatch '@inline$') { $plugins += $id }
        }
    }

    # 2. MCP servers != executor (leídos de ~/.claude.json; -AsHashtable por claves vacías).
    $claudeJson = "$env:USERPROFILE\.claude.json"
    if (Test-Path $claudeJson) {
        try {
            $cfg = Get-Content $claudeJson -Raw | ConvertFrom-Json -AsHashtable
            if ($cfg.mcpServers) {
                foreach ($name in $cfg.mcpServers.Keys) { if ($name -ne 'executor') { $mcp += $name } }
            }
        } catch {}
    }

    # 3. Skills en ~/.claude/skills que NO son symlinks a $repo\claude\skills.
    $skillsDir = "$env:USERPROFILE\.claude\skills"
    $repoSkills = "$repo\claude\skills"
    if (Test-Path $skillsDir) {
        Get-ChildItem -Path $skillsDir -Force | ForEach-Object {
            $isRepoLink = ($_.LinkType -eq 'SymbolicLink') -and $_.Target -and `
                $_.Target.StartsWith($repoSkills, [StringComparison]::OrdinalIgnoreCase)
            if (-not $isRepoLink) { $skills += $_.FullName }
        }
    }

    # 4. Rules sueltos y settings.local.json global (no vienen del repo).
    $rulesDir = "$env:USERPROFILE\.claude\rules"
    if (Test-Path $rulesDir) {
        Get-ChildItem -Path $rulesDir -Force -File -Recurse | ForEach-Object { $other += $_.FullName }
    }
    $localSettings = "$env:USERPROFILE\.claude\settings.local.json"
    if (Test-Path $localSettings) { $other += $localSettings }

    if (($plugins.Count + $mcp.Count + $skills.Count + $other.Count) -eq 0) {
        Write-Output "Limpieza: nada que quitar, Claude ya está en el baseline."
        return
    }

    Write-Output "`n=== Limpieza de Claude (fuera del baseline de dotfiles) ==="
    if ($plugins) { Write-Output "Plugins a desinstalar:";           $plugins | ForEach-Object { Write-Output "  - $_" } }
    if ($mcp)     { Write-Output "MCP servers a quitar:";            $mcp     | ForEach-Object { Write-Output "  - $_" } }
    if ($skills)  { Write-Output "Skills sueltas a borrar:";         $skills  | ForEach-Object { Write-Output "  - $_" } }
    if ($other)   { Write-Output "Rules / settings.local a borrar:"; $other   | ForEach-Object { Write-Output "  - $_" } }

    $ans = Read-Host "`nProceder con la limpieza? (y/N)"
    if ($ans -notmatch '^[ysYS]') { Write-Output "Limpieza omitida."; return }

    foreach ($p in $plugins) { claude plugin uninstall $p -y --scope user 2>$null; Write-Output "Desinstalado plugin: $p" }
    foreach ($m in $mcp)     { claude mcp remove $m --scope user 2>$null;          Write-Output "Quitado MCP: $m" }
    foreach ($s in $skills)  { Remove-Item $s -Recurse -Force;                     Write-Output "Borrada skill suelta: $s" }
    foreach ($o in $other)   { Remove-Item $o -Force;                              Write-Output "Borrado: $o" }
    Write-Output "Limpieza completada."
}

Link-Config "$env:USERPROFILE\.wezterm.lua" "$repo\wezterm\.wezterm.lua"
Link-Config "$env:USERPROFILE\.config\oh-my-posh\material.omp.json" "$repo\oh-my-posh\material.omp.json"
Link-Config "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "$repo\powershell\Microsoft.PowerShell_profile.ps1"
Link-Config "$env:USERPROFILE\.claude\settings.json" "$repo\claude\settings.json"
Link-Config "$env:USERPROFILE\.claude\CLAUDE.md" "$repo\claude\CLAUDE.md"
# Link each skill individually so repo-managed skills coexist with local/plugin ones.
Get-ChildItem -Path "$repo\claude\skills" -Directory | ForEach-Object {
    Link-Config "$env:USERPROFILE\.claude\skills\$($_.Name)" $_.FullName
}

# Git: materialize symlinks natively. Los repos de proyecto usan symlinks
# .claude/skills → .agents/skills; sin esto, git en Windows los checkoutea como
# archivos de texto planos (rotos). Requiere Modo de desarrollador (ver arriba).
git config --global core.symlinks true

# --- Claude Code: MCP + plugins (not symlinkable — live in ~/.claude.json / plugin store) ---
if (Get-Command claude -ErrorAction SilentlyContinue) {
    # Executor: single MCP hub for all external integrations (Notion, Context7, Vercel, ...).
    # Connections themselves are managed at executor.sh; first use prompts an OAuth authorize.
    $executorUrl = "https://executor.sh/felipe-giraldo-s-organization/mcp"
    if ((claude mcp list 2>$null) -notmatch "executor") {
        claude mcp add --transport http executor $executorUrl --scope user
        Write-Output "Added Executor MCP (run /mcp in Claude Code to authorize)"
    } else {
        Write-Output "Executor MCP already configured"
    }

    # Only plugin we keep is superpowers.
    if ((claude plugin list 2>$null) -notmatch "superpowers") {
        claude plugin install superpowers@claude-plugins-official
    } else {
        Write-Output "superpowers plugin already installed"
    }

    # Limpieza: quita lo que sobre respecto al baseline (corre tras linkear skills
    # para no marcar como "sueltas" las que este script acaba de symlinkear).
    Clean-ClaudeBaseline $repo
} else {
    Write-Warning "claude CLI not found — skipping Executor MCP + superpowers plugin. Install Claude Code, then re-run this script."
}

Write-Output "`nDone. Make sure these are installed: WezTerm, Oh My Posh (winget install JanDeDobbeleer.OhMyPosh), JetBrainsMono Nerd Font, Claude Code."
Write-Output "After first run, open Claude Code and run /mcp to authorize Executor (Notion, Context7, Vercel connections)."
