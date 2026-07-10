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
} else {
    Write-Warning "claude CLI not found — skipping Executor MCP + superpowers plugin. Install Claude Code, then re-run this script."
}

Write-Output "`nDone. Make sure these are installed: WezTerm, Oh My Posh (winget install JanDeDobbeleer.OhMyPosh), JetBrainsMono Nerd Font, Claude Code."
Write-Output "After first run, open Claude Code and run /mcp to authorize Executor (Notion, Context7, Vercel connections)."
