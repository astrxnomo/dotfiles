# dotfiles

Personal config files, symlinked into place from here so they stay in sync across machines.

## Contents

- `wezterm/.wezterm.lua` — WezTerm terminal config (theme, keybindings, panes, tab bar)
- `oh-my-posh/material.omp.json` — Oh My Posh prompt theme (Material, tweaked)
- `powershell/Microsoft.PowerShell_profile.ps1` — PowerShell profile (Oh My Posh init + Linux-style aliases)

## Setup on a new PC

1. Install WezTerm, [Oh My Posh](https://ohmyposh.dev) (`winget install JanDeDobbeleer.OhMyPosh`), and a Nerd Font (JetBrainsMono Nerd Font).
2. Enable **Developer Mode** (Settings > Privacy & security > For developers) so symlinks can be created without admin.
3. Clone this repo and run:

   ```powershell
   git clone https://github.com/astrxnomo/dotfiles.git D:\Code\dotfiles
   D:\Code\dotfiles\install.ps1
   ```

4. Restart WezTerm / open a new PowerShell tab.
