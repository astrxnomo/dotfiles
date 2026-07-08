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
Link-Config $PROFILE "$repo\powershell\Microsoft.PowerShell_profile.ps1"
Link-Config "$env:USERPROFILE\.claude\settings.json" "$repo\claude\settings.json"
Link-Config "$env:USERPROFILE\.claude\CLAUDE.md" "$repo\claude\CLAUDE.md"
# Link each skill individually so repo-managed skills coexist with local/plugin ones.
Get-ChildItem -Path "$repo\claude\skills" -Directory | ForEach-Object {
    Link-Config "$env:USERPROFILE\.claude\skills\$($_.Name)" $_.FullName
}

Write-Output "`nDone. Make sure these are installed: WezTerm, Oh My Posh (winget install JanDeDobbeleer.OhMyPosh), JetBrainsMono Nerd Font, Claude Code."
