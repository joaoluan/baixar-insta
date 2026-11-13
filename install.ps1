# Instala o baixar-insta + camofox-browser + atalhos na Área de Trabalho do Windows.
$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CamofoxDir = if ($env:CAMOFOX_DIR) { $env:CAMOFOX_DIR } else { Join-Path $HOME "Projetos\camofox-browser" }
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "==> 1/3 Verificando Python 3, Node.js (>= 22) e Git..."
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Python 3 via winget..."
    winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Node.js LTS via winget..."
    winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Git via winget..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
}

Write-Host "==> 2/3 Configurando camofox-browser em $CamofoxDir..."
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $CamofoxDir) | Out-Null
if (-not (Test-Path (Join-Path $CamofoxDir ".git"))) {
    git clone https://github.com/jo-inc/camofox-browser.git $CamofoxDir
}
if (-not (Test-Path (Join-Path $CamofoxDir "node_modules"))) {
    Push-Location $CamofoxDir
    npm install
    Pop-Location
}

Write-Host "==> 3/3 Criando atalhos na Área de Trabalho ($DesktopDir)..."
$PythonExe = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
if (-not $PythonExe) { $PythonExe = (Get-Command python).Source }
$ScriptPath = Join-Path $RepoDir "baixar-insta"

$WshShell = New-Object -ComObject WScript.Shell

$Shortcut1 = $WshShell.CreateShortcut((Join-Path $DesktopDir "Baixar do Instagram.lnk"))
$Shortcut1.TargetPath = $PythonExe
$Shortcut1.Arguments = "`"$ScriptPath`""
$Shortcut1.WorkingDirectory = $RepoDir
$Shortcut1.Description = "Baixa fotos e vídeos de um link do Instagram"
$Shortcut1.Save()

$Shortcut2 = $WshShell.CreateShortcut((Join-Path $DesktopDir "Login Instagram (baixador).lnk"))
$Shortcut2.TargetPath = $PythonExe
$Shortcut2.Arguments = "`"$ScriptPath`" --login"
$Shortcut2.WorkingDirectory = $RepoDir
$Shortcut2.Description = "Entra na conta secundária do Instagram usada pelo Baixar do Instagram"
$Shortcut2.Save()

Write-Host ""
Write-Host "Pronto! Atalhos criados na Área de Trabalho:"
Write-Host "  - Baixar do Instagram"
Write-Host "  - Login Instagram (baixador)"
