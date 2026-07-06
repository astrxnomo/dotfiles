oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\material.omp.json" | Invoke-Expression

# --- Unix-like aliases (ls, cp, mv, rm, cat, pwd, clear ya vienen nativos en pwsh) ---
function touch { param([string]$Path) if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $Path | Out-Null } }
function which { param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue }
function grep { param([string]$Pattern, [string]$Path) if ($Path) { Select-String -Pattern $Pattern -Path $Path } else { $input | Select-String -Pattern $Pattern } }
function ll { Get-ChildItem -Force @args }
function export { param([string]$Assignment) $name, $value = $Assignment -split '=', 2; Set-Item -Path "Env:$name" -Value $value }
function mkdirp { param([string]$Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null }
