# Run this on a new PC to link these dotfiles into place.
# Requires Developer Mode enabled (Settings > Privacy & security > For developers)
# so that New-Item -ItemType SymbolicLink works without admin.

$repo = $PSScriptRoot

function Link-Config($target, $source) {
    $dir = Split-Path $target
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (Test-Path $target) {
        Remove-Item $target -Force -Recurse
    }
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Write-Output "Linked $target -> $source"
}

Link-Config "$env:USERPROFILE\.wezterm.lua" "$repo\wezterm\.wezterm.lua"
Link-Config "$env:USERPROFILE\.config\oh-my-posh\material.omp.json" "$repo\oh-my-posh\material.omp.json"
Link-Config $PROFILE "$repo\powershell\Microsoft.PowerShell_profile.ps1"

Write-Output "`nDone. Make sure these are installed: WezTerm, Oh My Posh (winget install JanDeDobbeleer.OhMyPosh), JetBrainsMono Nerd Font."
